import Foundation
import Metrics

/// Manages analytics and metrics for the real-time communication system
///
/// This class tracks performance metrics, user analytics, and system health
/// data. It provides comprehensive analytics capabilities for monitoring
/// the real-time communication framework's performance and usage.
///
/// ## Usage
///
/// ```swift
/// let manager = AnalyticsManager(configuration: config)
/// manager.trackEvent(.messageSent, properties: ["size": 1024])
/// ```
public class AnalyticsManager {
    
    // MARK: - Properties
    
    /// Configuration for the analytics manager
    private let configuration: RealTimeConfig
    
    /// Logger for debugging and monitoring
    private let logger: Logger
    
    /// Analytics data storage
    private var analyticsData = AnalyticsData()
    
    /// Event queue for batching
    private var eventQueue: [AnalyticsEvent] = []
    
    /// Metrics for performance tracking
    private let metrics = Metrics()
    
    /// Flush timer for batching events
    private var flushTimer: Timer?
    
    /// Analytics queue for processing
    private let analyticsQueue = DispatchQueue(label: "com.realtime.analytics", qos: .utility)
    
    /// Performance metrics
    private var performanceMetrics = PerformanceMetrics()
    
    /// User analytics
    private var userAnalytics = UserAnalytics()
    
    /// System health metrics
    private var systemHealthMetrics = SystemHealthMetrics()
    
    // MARK: - Initialization
    
    /// Creates a new analytics manager with the specified configuration
    /// - Parameter configuration: The configuration for the analytics manager
    public init(configuration: RealTimeConfig) {
        self.configuration = configuration
        self.logger = Logger(label: "com.realtime.analytics")
        
        setupMetrics()
        startFlushTimer()
        
        logger.info("AnalyticsManager initialized with configuration: \(configuration)")
    }
    
    deinit {
        flushTimer?.invalidate()
        flushEvents()
    }
    
    // MARK: - Public Methods
    
    /// Tracks an analytics event
    /// - Parameters:
    ///   - event: The event to track
    ///   - properties: Additional properties for the event
    public func trackEvent(_ event: AnalyticsEvent, properties: [String: Any] = [:]) {
        analyticsQueue.async { [weak self] in
            self?.processEvent(event, properties: properties)
        }
    }
    
    /// Tracks a performance metric
    /// - Parameters:
    ///   - metric: The metric to track
    ///   - value: The value of the metric
    ///   - unit: The unit of measurement
    public func trackMetric(_ metric: PerformanceMetric, value: Double, unit: String = "") {
        analyticsQueue.async { [weak self] in
            self?.processMetric(metric, value: value, unit: unit)
        }
    }
    
    /// Tracks user behavior
    /// - Parameters:
    ///   - action: The user action
    ///   - properties: Additional properties for the action
    public func trackUserAction(_ action: UserAction, properties: [String: Any] = [:]) {
        analyticsQueue.async { [weak self] in
            self?.processUserAction(action, properties: properties)
        }
    }
    
    /// Tracks system health metrics
    /// - Parameters:
    ///   - metric: The health metric to track
    ///   - value: The value of the metric
    public func trackSystemHealth(_ metric: SystemHealthMetric, value: Double) {
        analyticsQueue.async { [weak self] in
            self?.processSystemHealth(metric, value: value)
        }
    }
    
    /// Gets the current analytics data
    /// - Returns: Current analytics data
    public func getAnalytics() -> AnalyticsData {
        return analyticsData
    }
    
    /// Gets performance metrics
    /// - Returns: Current performance metrics
    public func getPerformanceMetrics() -> PerformanceMetrics {
        return performanceMetrics
    }
    
    /// Gets user analytics
    /// - Returns: Current user analytics
    public func getUserAnalytics() -> UserAnalytics {
        return userAnalytics
    }
    
    /// Gets system health metrics
    /// - Returns: Current system health metrics
    public func getSystemHealthMetrics() -> SystemHealthMetrics {
        return systemHealthMetrics
    }
    
    /// Flushes all pending analytics events
    public func flush() {
        analyticsQueue.async { [weak self] in
            self?.flushEvents()
        }
    }
    
    /// Resets all analytics data
    public func reset() {
        analyticsQueue.async { [weak self] in
            self?.resetAnalytics()
        }
    }
    
    // MARK: - Private Methods
    
    /// Sets up metrics for tracking
    private func setupMetrics() {
        // Initialize performance counters
        performanceMetrics.connectionLatency = Counter(label: "connection_latency")
        performanceMetrics.messageThroughput = Counter(label: "message_throughput")
        performanceMetrics.errorRate = Counter(label: "error_rate")
        performanceMetrics.memoryUsage = Gauge(label: "memory_usage")
        performanceMetrics.cpuUsage = Gauge(label: "cpu_usage")
        
        logger.debug("Metrics setup completed")
    }
    
    /// Starts the flush timer for batching events
    private func startFlushTimer() {
        flushTimer = Timer.scheduledTimer(withTimeInterval: configuration.analyticsFlushInterval, repeats: true) { [weak self] _ in
            self?.flush()
        }
        
        logger.debug("Analytics flush timer started with interval: \(configuration.analyticsFlushInterval)")
    }
    
    /// Processes an analytics event
    /// - Parameters:
    ///   - event: The event to process
    ///   - properties: Additional properties for the event
    private func processEvent(_ event: AnalyticsEvent, properties: [String: Any]) {
        let analyticsEvent = AnalyticsEvent(
            name: event.rawValue,
            properties: properties,
            timestamp: Date()
        )
        
        eventQueue.append(analyticsEvent)
        
        // Update analytics data
        analyticsData.totalEvents += 1
        analyticsData.lastUpdated = Date()
        
        // Track event frequency
        if let eventCount = analyticsData.eventFrequency[event.rawValue] {
            analyticsData.eventFrequency[event.rawValue] = eventCount + 1
        } else {
            analyticsData.eventFrequency[event.rawValue] = 1
        }
        
        logger.debug("Event tracked: \(event.rawValue) with properties: \(properties)")
    }
    
    /// Processes a performance metric
    /// - Parameters:
    ///   - metric: The metric to process
    ///   - value: The value of the metric
    ///   - unit: The unit of measurement
    private func processMetric(_ metric: PerformanceMetric, value: Double, unit: String) {
        switch metric {
        case .connectionLatency:
            performanceMetrics.connectionLatency?.increment(by: Int64(value))
            performanceMetrics.averageLatency = calculateAverageLatency(value)
            
        case .messageThroughput:
            performanceMetrics.messageThroughput?.increment(by: Int64(value))
            performanceMetrics.totalMessages += Int(value)
            
        case .errorRate:
            performanceMetrics.errorRate?.increment(by: Int64(value))
            performanceMetrics.totalErrors += Int(value)
            
        case .memoryUsage:
            performanceMetrics.memoryUsage?.record(value)
            performanceMetrics.currentMemoryUsage = value
            
        case .cpuUsage:
            performanceMetrics.cpuUsage?.record(value)
            performanceMetrics.currentCpuUsage = value
        }
        
        // Update analytics data
        analyticsData.lastUpdated = Date()
        
        logger.debug("Metric tracked: \(metric.rawValue) = \(value) \(unit)")
    }
    
    /// Processes a user action
    /// - Parameters:
    ///   - action: The user action to process
    ///   - properties: Additional properties for the action
    private func processUserAction(_ action: UserAction, properties: [String: Any]) {
        // Update user analytics
        userAnalytics.totalActions += 1
        userAnalytics.lastAction = Date()
        
        // Track action frequency
        if let actionCount = userAnalytics.actionFrequency[action.rawValue] {
            userAnalytics.actionFrequency[action.rawValue] = actionCount + 1
        } else {
            userAnalytics.actionFrequency[action.rawValue] = 1
        }
        
        // Track session duration
        if let sessionStart = userAnalytics.sessionStart {
            userAnalytics.sessionDuration = Date().timeIntervalSince(sessionStart)
        }
        
        // Update analytics data
        analyticsData.lastUpdated = Date()
        
        logger.debug("User action tracked: \(action.rawValue) with properties: \(properties)")
    }
    
    /// Processes a system health metric
    /// - Parameters:
    ///   - metric: The health metric to process
    ///   - value: The value of the metric
    private func processSystemHealth(_ metric: SystemHealthMetric, value: Double) {
        switch metric {
        case .connectionStability:
            systemHealthMetrics.connectionStability = value
            
        case .messageDeliveryRate:
            systemHealthMetrics.messageDeliveryRate = value
            
        case .errorFrequency:
            systemHealthMetrics.errorFrequency = value
            
        case .resourceUsage:
            systemHealthMetrics.resourceUsage = value
        }
        
        // Update analytics data
        analyticsData.lastUpdated = Date()
        
        logger.debug("System health tracked: \(metric.rawValue) = \(value)")
    }
    
    /// Flushes all pending events
    private func flushEvents() {
        guard !eventQueue.isEmpty else { return }
        
        // Process all pending events
        let events = eventQueue
        eventQueue.removeAll()
        
        // Send events to analytics service (placeholder)
        sendEventsToAnalyticsService(events)
        
        logger.info("Flushed \(events.count) analytics events")
    }
    
    /// Sends events to analytics service (placeholder implementation)
    /// - Parameter events: The events to send
    private func sendEventsToAnalyticsService(_ events: [AnalyticsEvent]) {
        // This would typically send events to an analytics service
        // For now, we'll just log them
        
        for event in events {
            logger.debug("Sending event to analytics service: \(event.name)")
        }
        
        // Track analytics
        analyticsData.eventsSent += events.count
        analyticsData.lastFlush = Date()
    }
    
    /// Resets all analytics data
    private func resetAnalytics() {
        analyticsData = AnalyticsData()
        performanceMetrics = PerformanceMetrics()
        userAnalytics = UserAnalytics()
        systemHealthMetrics = SystemHealthMetrics()
        eventQueue.removeAll()
        
        logger.info("Analytics data reset")
    }
    
    /// Calculates average latency
    /// - Parameter newValue: The new latency value
    /// - Returns: The updated average latency
    private func calculateAverageLatency(_ newValue: Double) -> Double {
        let currentAverage = performanceMetrics.averageLatency
        let totalMeasurements = performanceMetrics.latencyMeasurements
        
        if totalMeasurements == 0 {
            return newValue
        }
        
        return (currentAverage * Double(totalMeasurements) + newValue) / Double(totalMeasurements + 1)
    }
}

// MARK: - Supporting Types

/// Analytics event types
public enum AnalyticsEvent: String, CaseIterable {
    // Connection events
    case connectionEstablished = "connection_established"
    case connectionFailed = "connection_failed"
    case connectionClosed = "connection_closed"
    case connectionReconnected = "connection_reconnected"
    
    // Message events
    case messageSent = "message_sent"
    case messageReceived = "message_received"
    case messageFailed = "message_failed"
    case messageQueued = "message_queued"
    case messageProcessed = "message_processed"
    case messageRetried = "message_retried"
    
    // Push notification events
    case pushNotificationRegistered = "push_notification_registered"
    case pushNotificationReceived = "push_notification_received"
    case pushNotificationFailed = "push_notification_failed"
    
    // Queue events
    case queueFull = "queue_full"
    case queueCleared = "queue_cleared"
    case messageRemoved = "message_removed"
    case failedMessageRetried = "failed_message_retried"
    
    // System events
    case systemError = "system_error"
    case performanceAlert = "performance_alert"
    case healthCheck = "health_check"
}

/// Performance metric types
public enum PerformanceMetric: String, CaseIterable {
    case connectionLatency = "connection_latency"
    case messageThroughput = "message_throughput"
    case errorRate = "error_rate"
    case memoryUsage = "memory_usage"
    case cpuUsage = "cpu_usage"
}

/// User action types
public enum UserAction: String, CaseIterable {
    case messageSent = "message_sent"
    case messageReceived = "message_received"
    case connectionEstablished = "connection_established"
    case connectionLost = "connection_lost"
    case notificationReceived = "notification_received"
    case notificationTapped = "notification_tapped"
}

/// System health metric types
public enum SystemHealthMetric: String, CaseIterable {
    case connectionStability = "connection_stability"
    case messageDeliveryRate = "message_delivery_rate"
    case errorFrequency = "error_frequency"
    case resourceUsage = "resource_usage"
}

/// Analytics data structure
public struct AnalyticsData {
    public var totalEvents: Int = 0
    public var eventsSent: Int = 0
    public var eventFrequency: [String: Int] = [:]
    public var lastUpdated: Date = Date()
    public var lastFlush: Date?
    
    public init() {}
}

/// Performance metrics structure
public struct PerformanceMetrics {
    public var connectionLatency: Counter?
    public var messageThroughput: Counter?
    public var errorRate: Counter?
    public var memoryUsage: Gauge?
    public var cpuUsage: Gauge?
    
    public var averageLatency: Double = 0.0
    public var totalMessages: Int = 0
    public var totalErrors: Int = 0
    public var currentMemoryUsage: Double = 0.0
    public var currentCpuUsage: Double = 0.0
    public var latencyMeasurements: Int = 0
    
    public init() {}
}

/// User analytics structure
public struct UserAnalytics {
    public var totalActions: Int = 0
    public var actionFrequency: [String: Int] = [:]
    public var sessionStart: Date?
    public var sessionDuration: TimeInterval = 0.0
    public var lastAction: Date?
    
    public init() {}
}

/// System health metrics structure
public struct SystemHealthMetrics {
    public var connectionStability: Double = 0.0
    public var messageDeliveryRate: Double = 0.0
    public var errorFrequency: Double = 0.0
    public var resourceUsage: Double = 0.0
    
    public init() {}
}

/// Analytics event structure
public struct AnalyticsEvent {
    public let name: String
    public let properties: [String: Any]
    public let timestamp: Date
    
    public init(name: String, properties: [String: Any], timestamp: Date) {
        self.name = name
        self.properties = properties
        self.timestamp = timestamp
    }
} 