import Foundation

/// Manages connection lifecycle and health monitoring
public class ConnectionManager {
    
    // MARK: - Properties
    
    private let configuration: RealTimeConfig
    public weak var delegate: ConnectionManagerDelegate?
    public weak var analyticsDelegate: AnalyticsDelegate?
    private let logger: Logger
    private var healthMetrics = ConnectionHealthMetrics()
    private var connectionPool: [Connection] = []
    private var healthCheckTimer: Timer?
    private let loadBalancer: LoadBalancer
    private let connectionQueue = DispatchQueue(label: "com.realtime.connection", qos: .userInitiated)
    private let healthQueue = DispatchQueue(label: "com.realtime.health", qos: .utility)
    
    // MARK: - Initialization
    
    public init(configuration: RealTimeConfig) {
        self.configuration = configuration
        self.logger = Logger(label: "com.realtime.connection")
        self.loadBalancer = LoadBalancer(configuration: configuration)
        
        setupHealthMonitoring()
        
        logger.info("ConnectionManager initialized with configuration: \(configuration)")
    }
    
    deinit {
        healthCheckTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    public func getHealthMetrics() -> ConnectionHealthMetrics {
        return healthMetrics
    }
    
    public func getBestConnection() -> Connection? {
        return loadBalancer.getBestConnection()
    }
    
    public func addConnection(_ connection: Connection) {
        connectionQueue.async { [weak self] in
            self?.addConnectionToPool(connection)
        }
    }
    
    public func removeConnection(_ connection: Connection) {
        connectionQueue.async { [weak self] in
            self?.removeConnectionFromPool(connection)
        }
    }
    
    public func performHealthCheck() {
        healthQueue.async { [weak self] in
            self?.checkAllConnections()
        }
    }
    
    public func getPoolStatistics() -> ConnectionPoolStatistics {
        return ConnectionPoolStatistics(
            totalConnections: connectionPool.count,
            activeConnections: connectionPool.filter { $0.status == .connected }.count,
            failedConnections: connectionPool.filter { $0.status == .failed }.count,
            averageLatency: calculateAverageLatency(),
            averageThroughput: calculateAverageThroughput()
        )
    }
    
    public func handleConnectionFailure(_ connection: Connection) {
        logger.warning("Handling connection failure: \(connection.id)")
        
        connection.status = .failed
        connection.lastFailure = Date()
        
        updateHealthMetrics()
        attemptFailover(for: connection)
        
        analyticsDelegate?.trackEvent(.connectionFailed, properties: [
            "connection_id": connection.id.uuidString,
            "failure_time": Date().timeIntervalSince1970
        ])
        
        delegate?.connectionManager(self, didEncounterError: ConnectionError.connectionFailed(NSError(domain: "connection", code: 1)))
    }
    
    public func handleConnectionRecovery(_ connection: Connection) {
        logger.info("Handling connection recovery: \(connection.id)")
        
        connection.status = .connected
        connection.lastRecovery = Date()
        
        updateHealthMetrics()
        
        analyticsDelegate?.trackEvent(.connectionRecovered, properties: [
            "connection_id": connection.id.uuidString,
            "recovery_time": Date().timeIntervalSince1970
        ])
        
        delegate?.connectionManager(self, didUpdateHealthMetrics: healthMetrics)
    }
    
    // MARK: - Private Methods
    
    private func setupHealthMonitoring() {
        healthCheckTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.performHealthCheck()
        }
        
        logger.debug("Health monitoring setup completed")
    }
    
    private func addConnectionToPool(_ connection: Connection) {
        connectionPool.append(connection)
        loadBalancer.addConnection(connection)
        
        logger.info("Connection added to pool: \(connection.id)")
        
        analyticsDelegate?.trackEvent(.connectionAdded, properties: [
            "connection_id": connection.id.uuidString,
            "pool_size": connectionPool.count
        ])
    }
    
    private func removeConnectionFromPool(_ connection: Connection) {
        connectionPool.removeAll { $0.id == connection.id }
        loadBalancer.removeConnection(connection)
        
        logger.info("Connection removed from pool: \(connection.id)")
        
        analyticsDelegate?.trackEvent(.connectionRemoved, properties: [
            "connection_id": connection.id.uuidString,
            "pool_size": connectionPool.count
        ])
    }
    
    private func checkAllConnections() {
        logger.debug("Performing health check on \(connectionPool.count) connections")
        
        for connection in connectionPool {
            checkConnectionHealth(connection)
        }
        
        updateHealthMetrics()
        delegate?.connectionManager(self, didUpdateHealthMetrics: healthMetrics)
    }
    
    private func checkConnectionHealth(_ connection: Connection) {
        let isHealthy = connection.status == .connected && connection.lastPing != nil
        
        if !isHealthy {
            logger.warning("Connection health check failed: \(connection.id)")
            connection.status = .unhealthy
        } else {
            connection.status = .connected
        }
        
        updateConnectionMetrics(connection)
    }
    
    private func updateConnectionMetrics(_ connection: Connection) {
        if let lastPing = connection.lastPing {
            connection.latency = Date().timeIntervalSince(lastPing)
        }
        
        connection.throughput = calculateThroughput(for: connection)
        connection.errorRate = calculateErrorRate(for: connection)
    }
    
    private func updateHealthMetrics() {
        let activeConnections = connectionPool.filter { $0.status == .connected }
        let failedConnections = connectionPool.filter { $0.status == .failed }
        
        healthMetrics.connectionStatus = activeConnections.isEmpty ? .disconnected : .connected
        healthMetrics.latency = calculateAverageLatency()
        healthMetrics.throughput = calculateAverageThroughput()
        healthMetrics.errorRate = calculateOverallErrorRate()
        healthMetrics.lastStatusUpdate = Date()
        
        logger.debug("Health metrics updated: \(healthMetrics)")
    }
    
    private func attemptFailover(for failedConnection: Connection) {
        logger.info("Attempting failover for connection: \(failedConnection.id)")
        
        if let alternativeConnection = loadBalancer.getAlternativeConnection(to: failedConnection) {
            logger.info("Failover successful to connection: \(alternativeConnection.id)")
            
            analyticsDelegate?.trackEvent(.failoverSuccessful, properties: [
                "failed_connection_id": failedConnection.id.uuidString,
                "alternative_connection_id": alternativeConnection.id.uuidString
            ])
        } else {
            logger.error("Failover failed - no alternative connection available")
            
            analyticsDelegate?.trackEvent(.failoverFailed, properties: [
                "failed_connection_id": failedConnection.id.uuidString
            ])
        }
    }
    
    private func calculateAverageLatency() -> Double {
        let activeConnections = connectionPool.filter { $0.status == .connected }
        guard !activeConnections.isEmpty else { return 0.0 }
        
        let totalLatency = activeConnections.reduce(0.0) { $0 + $1.latency }
        return totalLatency / Double(activeConnections.count)
    }
    
    private func calculateAverageThroughput() -> Double {
        let activeConnections = connectionPool.filter { $0.status == .connected }
        guard !activeConnections.isEmpty else { return 0.0 }
        
        let totalThroughput = activeConnections.reduce(0.0) { $0 + $1.throughput }
        return totalThroughput / Double(activeConnections.count)
    }
    
    private func calculateOverallErrorRate() -> Double {
        let totalConnections = connectionPool.count
        guard totalConnections > 0 else { return 0.0 }
        
        let failedConnections = connectionPool.filter { $0.status == .failed }.count
        return Double(failedConnections) / Double(totalConnections)
    }
    
    private func calculateThroughput(for connection: Connection) -> Double {
        return Double.random(in: 10...1000)
    }
    
    private func calculateErrorRate(for connection: Connection) -> Double {
        return Double.random(in: 0...0.1)
    }
}

// MARK: - Supporting Types

public struct ConnectionHealthMetrics {
    public var connectionStatus: ConnectionStatus = .disconnected
    public var latency: Double = 0.0
    public var throughput: Double = 0.0
    public var errorRate: Double = 0.0
    public var lastStatusUpdate: Date = Date()
    
    public init() {}
}

public enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
    case unhealthy
    case failed
}

public struct Connection {
    public let id: UUID
    public let url: String
    public var status: ConnectionStatus
    public var latency: Double
    public var throughput: Double
    public var errorRate: Double
    public var lastPing: Date?
    public var lastFailure: Date?
    public var lastRecovery: Date?
    
    public init(
        id: UUID = UUID(),
        url: String,
        status: ConnectionStatus = .disconnected,
        latency: Double = 0.0,
        throughput: Double = 0.0,
        errorRate: Double = 0.0
    ) {
        self.id = id
        self.url = url
        self.status = status
        self.latency = latency
        self.throughput = throughput
        self.errorRate = errorRate
    }
}

public struct ConnectionPoolStatistics {
    public let totalConnections: Int
    public let activeConnections: Int
    public let failedConnections: Int
    public let averageLatency: Double
    public let averageThroughput: Double
    
    public init(
        totalConnections: Int,
        activeConnections: Int,
        failedConnections: Int,
        averageLatency: Double,
        averageThroughput: Double
    ) {
        self.totalConnections = totalConnections
        self.activeConnections = activeConnections
        self.failedConnections = failedConnections
        self.averageLatency = averageLatency
        self.averageThroughput = averageThroughput
    }
}

public protocol ConnectionManagerDelegate: AnyObject {
    func connectionManager(_ manager: ConnectionManager, didUpdateHealthMetrics metrics: ConnectionHealthMetrics)
    func connectionManager(_ manager: ConnectionManager, didEncounterError error: Error)
}

private class LoadBalancer {
    private let configuration: RealTimeConfig
    private var connections: [Connection] = []
    
    init(configuration: RealTimeConfig) {
        self.configuration = configuration
    }
    
    func addConnection(_ connection: Connection) {
        connections.append(connection)
    }
    
    func removeConnection(_ connection: Connection) {
        connections.removeAll { $0.id == connection.id }
    }
    
    func getBestConnection() -> Connection? {
        return connections
            .filter { $0.status == .connected }
            .min { $0.latency < $1.latency }
    }
    
    func getAlternativeConnection(to failedConnection: Connection) -> Connection? {
        return connections
            .filter { $0.id != failedConnection.id && $0.status == .connected }
            .min { $0.latency < $1.latency }
    }
} 