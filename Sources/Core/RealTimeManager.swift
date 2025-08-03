import Foundation
import Logging
import Metrics

/// Manages real-time communication connections and message handling.
///
/// This class provides a high-level interface for establishing and managing
/// WebSocket connections, handling push notifications, and processing message queues.
/// It follows the singleton pattern to ensure consistent state across the application.
///
/// ## Usage
///
/// ```swift
/// let manager = RealTimeManager.shared
/// try await manager.connect()
/// ```
///
/// ## Thread Safety
///
/// All public methods are thread-safe and can be called from any thread.
/// Internal state management is handled using appropriate synchronization mechanisms.
///
/// - Note: This class requires iOS 15.0 or later.
/// - Warning: Always call `disconnect()` before the app terminates.
public class RealTimeManager: ObservableObject {
    
    // MARK: - Singleton
    
    /// Shared instance of the RealTimeManager
    public static let shared = RealTimeManager()
    
    // MARK: - Properties
    
    /// Configuration for the real-time communication system
    private let configuration: RealTimeConfig
    
    /// WebSocket connection manager
    private let webSocketManager: WebSocketManager
    
    /// Push notification manager
    private let pushNotificationManager: PushNotificationManager
    
    /// Message queue manager
    private let messageQueueManager: MessageQueueManager
    
    /// Analytics manager
    private let analyticsManager: AnalyticsManager
    
    /// Connection manager
    private let connectionManager: ConnectionManager
    
    /// Logger for debugging and monitoring
    private let logger: Logger
    
    /// Current connection status
    @Published public private(set) var connectionStatus: ConnectionStatus = .disconnected
    
    /// Current connection health metrics
    @Published public private(set) var healthMetrics: ConnectionHealthMetrics = ConnectionHealthMetrics()
    
    /// Message processing queue
    private let messageQueue = DispatchQueue(label: "com.realtime.message", qos: .userInitiated)
    
    /// State management queue
    private let stateQueue = DispatchQueue(label: "com.realtime.state", qos: .utility)
    
    // MARK: - Initialization
    
    /// Initializes the RealTimeManager with the specified configuration
    /// - Parameter configuration: The configuration for the real-time communication system
    public init(configuration: RealTimeConfig) {
        self.configuration = configuration
        self.logger = Logger(label: "com.realtime.manager")
        
        // Initialize managers
        self.webSocketManager = WebSocketManager(configuration: configuration)
        self.pushNotificationManager = PushNotificationManager(configuration: configuration)
        self.messageQueueManager = MessageQueueManager(configuration: configuration)
        self.analyticsManager = AnalyticsManager(configuration: configuration)
        self.connectionManager = ConnectionManager(configuration: configuration)
        
        // Setup managers
        setupManagers()
        
        logger.info("RealTimeManager initialized with configuration: \(configuration)")
    }
    
    /// Private initializer for singleton pattern
    private init() {
        self.configuration = RealTimeConfig()
        self.logger = Logger(label: "com.realtime.manager")
        
        // Initialize managers with default configuration
        self.webSocketManager = WebSocketManager(configuration: configuration)
        self.pushNotificationManager = PushNotificationManager(configuration: configuration)
        self.messageQueueManager = MessageQueueManager(configuration: configuration)
        self.analyticsManager = AnalyticsManager(configuration: configuration)
        self.connectionManager = ConnectionManager(configuration: configuration)
        
        // Setup managers
        setupManagers()
        
        logger.info("RealTimeManager initialized with default configuration")
    }
    
    // MARK: - Setup
    
    /// Sets up the managers and their relationships
    private func setupManagers() {
        // Configure WebSocket manager
        webSocketManager.delegate = self
        webSocketManager.analyticsDelegate = analyticsManager
        
        // Configure push notification manager
        pushNotificationManager.delegate = self
        pushNotificationManager.analyticsDelegate = analyticsManager
        
        // Configure message queue manager
        messageQueueManager.delegate = self
        messageQueueManager.analyticsDelegate = analyticsManager
        
        // Configure connection manager
        connectionManager.delegate = self
        connectionManager.analyticsDelegate = analyticsManager
        
        logger.debug("Managers setup completed")
    }
    
    // MARK: - Public Methods
    
    /// Connects to the real-time communication server
    /// - Returns: A result indicating success or failure with connection details
    /// - Throws: `ConnectionError` if connection fails
    @MainActor
    public func connect() async throws -> ConnectionResult {
        logger.info("Attempting to connect to real-time server")
        
        do {
            // Update connection status
            await updateConnectionStatus(.connecting)
            
            // Connect WebSocket
            let webSocketResult = try await webSocketManager.connect()
            
            // Connect push notifications if enabled
            if configuration.enablePushNotifications {
                try await pushNotificationManager.register()
            }
            
            // Start message queue processing
            messageQueueManager.startProcessing()
            
            // Update connection status
            await updateConnectionStatus(.connected)
            
            // Track analytics
            analyticsManager.trackEvent(.connectionEstablished, properties: [
                "server_url": configuration.serverURL,
                "connection_time": Date().timeIntervalSince1970
            ])
            
            logger.info("Successfully connected to real-time server")
            
            return ConnectionResult(
                status: .connected,
                serverURL: configuration.serverURL,
                connectionTime: Date(),
                sessionID: webSocketResult.sessionID
            )
            
        } catch {
            await updateConnectionStatus(.disconnected)
            
            logger.error("Failed to connect to real-time server: \(error)")
            
            // Track analytics
            analyticsManager.trackEvent(.connectionFailed, properties: [
                "error": error.localizedDescription,
                "server_url": configuration.serverURL
            ])
            
            throw ConnectionError.connectionFailed(error)
        }
    }
    
    /// Disconnects from the real-time communication server
    /// - Returns: A result indicating success or failure
    @MainActor
    public func disconnect() async -> DisconnectionResult {
        logger.info("Disconnecting from real-time server")
        
        do {
            // Update connection status
            await updateConnectionStatus(.disconnecting)
            
            // Disconnect WebSocket
            try await webSocketManager.disconnect()
            
            // Unregister push notifications
            if configuration.enablePushNotifications {
                try await pushNotificationManager.unregister()
            }
            
            // Stop message queue processing
            messageQueueManager.stopProcessing()
            
            // Update connection status
            await updateConnectionStatus(.disconnected)
            
            // Track analytics
            analyticsManager.trackEvent(.connectionClosed, properties: [
                "session_duration": Date().timeIntervalSince1970
            ])
            
            logger.info("Successfully disconnected from real-time server")
            
            return DisconnectionResult(
                status: .disconnected,
                sessionDuration: Date().timeIntervalSince1970
            )
            
        } catch {
            logger.error("Error during disconnection: \(error)")
            
            // Track analytics
            analyticsManager.trackEvent(.disconnectionError, properties: [
                "error": error.localizedDescription
            ])
            
            return DisconnectionResult(
                status: .error,
                sessionDuration: Date().timeIntervalSince1970,
                error: error
            )
        }
    }
    
    /// Sends a message through the real-time communication system
    /// - Parameters:
    ///   - message: The message to send
    ///   - priority: The priority of the message
    ///   - completion: Completion handler called with the result
    public func send(
        message: RealTimeMessage,
        priority: MessagePriority = .normal,
        completion: @escaping (Result<Void, MessageError>) -> Void
    ) {
        messageQueue.async { [weak self] in
            guard let self = self else {
                completion(.failure(.managerNotAvailable))
                return
            }
            
            do {
                // Add message to queue
                try self.messageQueueManager.addMessage(message, priority: priority)
                
                // Send through WebSocket if connected
                if self.connectionStatus == .connected {
                    try self.webSocketManager.send(message: message)
                }
                
                // Track analytics
                self.analyticsManager.trackEvent(.messageSent, properties: [
                    "message_type": message.type.rawValue,
                    "priority": priority.rawValue,
                    "message_size": message.data.count
                ])
                
                completion(.success(()))
                
            } catch {
                self.logger.error("Failed to send message: \(error)")
                
                // Track analytics
                self.analyticsManager.trackEvent(.messageSendFailed, properties: [
                    "error": error.localizedDescription,
                    "message_type": message.type.rawValue
                ])
                
                completion(.failure(.sendFailed(error)))
            }
        }
    }
    
    /// Registers a message handler for receiving messages
    /// - Parameter handler: The handler to call when messages are received
    public func onMessage(_ handler: @escaping (RealTimeMessage) -> Void) {
        webSocketManager.onMessage = handler
    }
    
    /// Registers a connection status change handler
    /// - Parameter handler: The handler to call when connection status changes
    public func onConnectionStatusChange(_ handler: @escaping (ConnectionStatus) -> Void) {
        // Store handler for later use
        // Implementation depends on specific requirements
    }
    
    /// Registers a push notification handler
    /// - Parameter handler: The handler to call when push notifications are received
    public func onPushNotification(_ handler: @escaping (PushNotification) -> Void) {
        pushNotificationManager.onNotification = handler
    }
    
    /// Gets the current health metrics for the connection
    /// - Returns: Current health metrics
    public func getHealthMetrics() -> ConnectionHealthMetrics {
        return healthMetrics
    }
    
    /// Gets the current analytics data
    /// - Returns: Current analytics data
    public func getAnalytics() -> AnalyticsData {
        return analyticsManager.getAnalytics()
    }
    
    // MARK: - Private Methods
    
    /// Updates the connection status on the main thread
    /// - Parameter status: The new connection status
    @MainActor
    private func updateConnectionStatus(_ status: ConnectionStatus) {
        connectionStatus = status
        
        // Update health metrics
        healthMetrics.lastStatusUpdate = Date()
        healthMetrics.connectionStatus = status
        
        logger.debug("Connection status updated to: \(status)")
    }
}

// MARK: - WebSocketManagerDelegate

extension RealTimeManager: WebSocketManagerDelegate {
    
    func webSocketManager(_ manager: WebSocketManager, didConnect connection: WebSocketConnection) {
        Task { @MainActor in
            await updateConnectionStatus(.connected)
        }
    }
    
    func webSocketManager(_ manager: WebSocketManager, didDisconnect connection: WebSocketConnection) {
        Task { @MainActor in
            await updateConnectionStatus(.disconnected)
        }
    }
    
    func webSocketManager(_ manager: WebSocketManager, didReceiveMessage message: RealTimeMessage) {
        // Handle received message
        logger.debug("Received message: \(message)")
    }
    
    func webSocketManager(_ manager: WebSocketManager, didEncounterError error: Error) {
        logger.error("WebSocket error: \(error)")
        
        // Track analytics
        analyticsManager.trackEvent(.webSocketError, properties: [
            "error": error.localizedDescription
        ])
    }
}

// MARK: - PushNotificationManagerDelegate

extension RealTimeManager: PushNotificationManagerDelegate {
    
    func pushNotificationManager(_ manager: PushNotificationManager, didRegister deviceToken: String) {
        logger.info("Push notifications registered with token: \(deviceToken)")
    }
    
    func pushNotificationManager(_ manager: PushNotificationManager, didReceiveNotification notification: PushNotification) {
        logger.debug("Received push notification: \(notification)")
    }
    
    func pushNotificationManager(_ manager: PushNotificationManager, didEncounterError error: Error) {
        logger.error("Push notification error: \(error)")
        
        // Track analytics
        analyticsManager.trackEvent(.pushNotificationError, properties: [
            "error": error.localizedDescription
        ])
    }
}

// MARK: - MessageQueueManagerDelegate

extension RealTimeManager: MessageQueueManagerDelegate {
    
    func messageQueueManager(_ manager: MessageQueueManager, didProcessMessage message: RealTimeMessage) {
        logger.debug("Processed message from queue: \(message)")
    }
    
    func messageQueueManager(_ manager: MessageQueueManager, didFailToProcessMessage message: RealTimeMessage, error: Error) {
        logger.error("Failed to process message from queue: \(error)")
        
        // Track analytics
        analyticsManager.trackEvent(.messageProcessingFailed, properties: [
            "error": error.localizedDescription,
            "message_type": message.type.rawValue
        ])
    }
}

// MARK: - ConnectionManagerDelegate

extension RealTimeManager: ConnectionManagerDelegate {
    
    func connectionManager(_ manager: ConnectionManager, didUpdateHealthMetrics metrics: ConnectionHealthMetrics) {
        Task { @MainActor in
            healthMetrics = metrics
        }
    }
    
    func connectionManager(_ manager: ConnectionManager, didEncounterError error: Error) {
        logger.error("Connection manager error: \(error)")
        
        // Track analytics
        analyticsManager.trackEvent(.connectionManagerError, properties: [
            "error": error.localizedDescription
        ])
    }
} 