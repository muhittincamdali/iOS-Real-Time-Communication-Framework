import Foundation
import NIO
import NIOHTTP1
import NIOWebSocket

/// Manages WebSocket connections and message handling
///
/// This class handles the lifecycle of WebSocket connections, including
/// connection establishment, message sending/receiving, and error handling.
/// It provides a high-level interface for WebSocket communication with
/// automatic reconnection and heartbeat management.
///
/// ## Usage
///
/// ```swift
/// let manager = WebSocketManager(configuration: config)
/// try await manager.connect()
/// ```
public class WebSocketManager {
    
    // MARK: - Properties
    
    /// Configuration for the WebSocket manager
    private let configuration: RealTimeConfig
    
    /// Current WebSocket connection
    private var connection: WebSocketConnection?
    
    /// Event loop group for WebSocket operations
    private let eventLoopGroup: EventLoopGroup
    
    /// Message handler for received messages
    public var onMessage: ((RealTimeMessage) -> Void)?
    
    /// Delegate for WebSocket events
    public weak var delegate: WebSocketManagerDelegate?
    
    /// Analytics delegate for tracking events
    public weak var analyticsDelegate: AnalyticsDelegate?
    
    /// Logger for debugging and monitoring
    private let logger: Logger
    
    /// Connection state
    private var connectionState: ConnectionState = .disconnected
    
    /// Reconnection state
    private var reconnectionState: ReconnectionState = ReconnectionState()
    
    /// Heartbeat timer
    private var heartbeatTimer: Timer?
    
    /// Message queue for outgoing messages
    private let messageQueue = DispatchQueue(label: "com.realtime.websocket.message", qos: .userInitiated)
    
    /// State management queue
    private let stateQueue = DispatchQueue(label: "com.realtime.websocket.state", qos: .utility)
    
    // MARK: - Initialization
    
    /// Creates a new WebSocket manager with the specified configuration
    /// - Parameter configuration: The configuration for the WebSocket manager
    public init(configuration: RealTimeConfig) {
        self.configuration = configuration
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.logger = Logger(label: "com.realtime.websocket")
        
        logger.info("WebSocketManager initialized with configuration: \(configuration)")
    }
    
    deinit {
        eventLoopGroup.shutdownGracefully { error in
            if let error = error {
                self.logger.error("Error shutting down event loop group: \(error)")
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Connects to the WebSocket server
    /// - Returns: A result containing connection details
    /// - Throws: `ConnectionError` if connection fails
    public func connect() async throws -> WebSocketConnectionResult {
        logger.info("Attempting to connect to WebSocket server: \(configuration.serverURL)")
        
        do {
            // Update connection state
            await updateConnectionState(.connecting)
            
            // Create WebSocket connection
            let connection = try await createWebSocketConnection()
            
            // Store connection
            self.connection = connection
            
            // Start heartbeat
            startHeartbeat()
            
            // Update connection state
            await updateConnectionState(.connected)
            
            // Notify delegate
            delegate?.webSocketManager(self, didConnect: connection)
            
            // Track analytics
            analyticsDelegate?.trackEvent(.webSocketConnected, properties: [
                "server_url": configuration.serverURL,
                "connection_time": Date().timeIntervalSince1970
            ])
            
            logger.info("Successfully connected to WebSocket server")
            
            return WebSocketConnectionResult(
                sessionID: UUID().uuidString,
                serverURL: configuration.serverURL,
                connectionTime: Date()
            )
            
        } catch {
            await updateConnectionState(.disconnected)
            
            logger.error("Failed to connect to WebSocket server: \(error)")
            
            // Track analytics
            analyticsDelegate?.trackEvent(.webSocketConnectionFailed, properties: [
                "error": error.localizedDescription,
                "server_url": configuration.serverURL
            ])
            
            throw ConnectionError.connectionFailed(error)
        }
    }
    
    /// Disconnects from the WebSocket server
    /// - Throws: `ConnectionError` if disconnection fails
    public func disconnect() async throws {
        logger.info("Disconnecting from WebSocket server")
        
        do {
            // Stop heartbeat
            stopHeartbeat()
            
            // Close connection
            if let connection = connection {
                try await connection.close()
                self.connection = nil
            }
            
            // Update connection state
            await updateConnectionState(.disconnected)
            
            // Reset reconnection state
            reconnectionState = ReconnectionState()
            
            // Track analytics
            analyticsDelegate?.trackEvent(.webSocketDisconnected, properties: [
                "session_duration": Date().timeIntervalSince1970
            ])
            
            logger.info("Successfully disconnected from WebSocket server")
            
        } catch {
            logger.error("Error during WebSocket disconnection: \(error)")
            
            // Track analytics
            analyticsDelegate?.trackEvent(.webSocketDisconnectionError, properties: [
                "error": error.localizedDescription
            ])
            
            throw ConnectionError.disconnectionFailed(error)
        }
    }
    
    /// Sends a message through the WebSocket connection
    /// - Parameter message: The message to send
    /// - Throws: `MessageError` if sending fails
    public func send(message: RealTimeMessage) throws {
        guard let connection = connection, connectionState == .connected else {
            throw MessageError.connectionNotAvailable
        }
        
        messageQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                // Serialize message
                let data = try self.serializeMessage(message)
                
                // Send through WebSocket
                try connection.send(data: data)
                
                // Track analytics
                self.analyticsDelegate?.trackEvent(.messageSent, properties: [
                    "message_type": message.type.rawValue,
                    "message_size": data.count
                ])
                
                self.logger.debug("Message sent successfully: \(message)")
                
            } catch {
                self.logger.error("Failed to send message: \(error)")
                
                // Track analytics
                self.analyticsDelegate?.trackEvent(.messageSendFailed, properties: [
                    "error": error.localizedDescription,
                    "message_type": message.type.rawValue
                ])
                
                // Notify delegate
                self.delegate?.webSocketManager(self, didEncounterError: error)
            }
        }
    }
    
    /// Checks if the WebSocket connection is currently connected
    /// - Returns: True if connected, false otherwise
    public var isConnected: Bool {
        return connectionState == .connected && connection != nil
    }
    
    // MARK: - Private Methods
    
    /// Creates a new WebSocket connection
    /// - Returns: A WebSocket connection
    /// - Throws: `ConnectionError` if connection creation fails
    private func createWebSocketConnection() async throws -> WebSocketConnection {
        let url = URL(string: configuration.serverURL)!
        
        // Create WebSocket client
        let client = WebSocketClient(
            eventLoopGroup: eventLoopGroup,
            configuration: configuration
        )
        
        // Connect to server
        let connection = try await client.connect(to: url)
        
        // Setup message handler
        connection.onMessage = { [weak self] data in
            self?.handleReceivedMessage(data)
        }
        
        // Setup close handler
        connection.onClose = { [weak self] in
            self?.handleConnectionClosed()
        }
        
        // Setup error handler
        connection.onError = { [weak self] error in
            self?.handleConnectionError(error)
        }
        
        return connection
    }
    
    /// Handles received WebSocket messages
    /// - Parameter data: The received message data
    private func handleReceivedMessage(_ data: Data) {
        do {
            // Deserialize message
            let message = try deserializeMessage(data)
            
            // Notify message handler
            onMessage?(message)
            
            // Track analytics
            analyticsDelegate?.trackEvent(.messageReceived, properties: [
                "message_type": message.type.rawValue,
                "message_size": data.count
            ])
            
            logger.debug("Message received: \(message)")
            
        } catch {
            logger.error("Failed to deserialize received message: \(error)")
            
            // Track analytics
            analyticsDelegate?.trackEvent(.messageDeserializationFailed, properties: [
                "error": error.localizedDescription
            ])
        }
    }
    
    /// Handles WebSocket connection closure
    private func handleConnectionClosed() {
        logger.info("WebSocket connection closed")
        
        Task { @MainActor in
            await updateConnectionState(.disconnected)
        }
        
        // Stop heartbeat
        stopHeartbeat()
        
        // Notify delegate
        delegate?.webSocketManager(self, didDisconnect: connection!)
        
        // Track analytics
        analyticsDelegate?.trackEvent(.webSocketConnectionClosed, properties: [
            "session_duration": Date().timeIntervalSince1970
        ])
        
        // Attempt reconnection if enabled
        if configuration.maxReconnectionAttempts > 0 {
            attemptReconnection()
        }
    }
    
    /// Handles WebSocket connection errors
    /// - Parameter error: The error that occurred
    private func handleConnectionError(_ error: Error) {
        logger.error("WebSocket connection error: \(error)")
        
        // Notify delegate
        delegate?.webSocketManager(self, didEncounterError: error)
        
        // Track analytics
        analyticsDelegate?.trackEvent(.webSocketError, properties: [
            "error": error.localizedDescription
        ])
    }
    
    /// Attempts to reconnect to the WebSocket server
    private func attemptReconnection() {
        guard reconnectionState.attempts < configuration.maxReconnectionAttempts else {
            logger.warning("Maximum reconnection attempts reached")
            return
        }
        
        reconnectionState.attempts += 1
        
        let delay = configuration.reconnectionDelay * pow(configuration.reconnectionBackoffMultiplier, Double(reconnectionState.attempts - 1))
        
        logger.info("Attempting reconnection \(reconnectionState.attempts)/\(configuration.maxReconnectionAttempts) in \(delay) seconds")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.performReconnection()
        }
    }
    
    /// Performs the actual reconnection attempt
    private func performReconnection() {
        Task {
            do {
                try await connect()
                logger.info("Reconnection successful")
                
                // Reset reconnection state
                reconnectionState = ReconnectionState()
                
            } catch {
                logger.error("Reconnection failed: \(error)")
                
                // Attempt another reconnection
                attemptReconnection()
            }
        }
    }
    
    /// Starts the heartbeat timer
    private func startHeartbeat() {
        guard configuration.heartbeatInterval > 0 else { return }
        
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: configuration.heartbeatInterval, repeats: true) { [weak self] _ in
            self?.sendHeartbeat()
        }
        
        logger.debug("Heartbeat timer started with interval: \(configuration.heartbeatInterval)")
    }
    
    /// Stops the heartbeat timer
    private func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
        
        logger.debug("Heartbeat timer stopped")
    }
    
    /// Sends a heartbeat message
    private func sendHeartbeat() {
        guard isConnected else { return }
        
        do {
            let heartbeatMessage = RealTimeMessage(
                id: UUID(),
                type: .heartbeat,
                data: Data(),
                timestamp: Date()
            )
            
            try send(message: heartbeatMessage)
            
            logger.debug("Heartbeat sent")
            
        } catch {
            logger.error("Failed to send heartbeat: \(error)")
        }
    }
    
    /// Serializes a message to data
    /// - Parameter message: The message to serialize
    /// - Returns: Serialized message data
    /// - Throws: `MessageError` if serialization fails
    private func serializeMessage(_ message: RealTimeMessage) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        return try encoder.encode(message)
    }
    
    /// Deserializes data to a message
    /// - Parameter data: The data to deserialize
    /// - Returns: Deserialized message
    /// - Throws: `MessageError` if deserialization fails
    private func deserializeMessage(_ data: Data) throws -> RealTimeMessage {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(RealTimeMessage.self, from: data)
    }
    
    /// Updates the connection state on the main thread
    /// - Parameter state: The new connection state
    @MainActor
    private func updateConnectionState(_ state: ConnectionState) {
        connectionState = state
        logger.debug("Connection state updated to: \(state)")
    }
}

// MARK: - Supporting Types

/// Connection state for WebSocket
public enum ConnectionState {
    case disconnected
    case connecting
    case connected
    case reconnecting
}

/// Reconnection state
public struct ReconnectionState {
    public var attempts: Int = 0
    public var lastAttempt: Date?
    
    public init() {}
}

/// WebSocket connection result
public struct WebSocketConnectionResult {
    public let sessionID: String
    public let serverURL: String
    public let connectionTime: Date
}

/// WebSocket manager delegate
public protocol WebSocketManagerDelegate: AnyObject {
    func webSocketManager(_ manager: WebSocketManager, didConnect connection: WebSocketConnection)
    func webSocketManager(_ manager: WebSocketManager, didDisconnect connection: WebSocketConnection)
    func webSocketManager(_ manager: WebSocketManager, didReceiveMessage message: RealTimeMessage)
    func webSocketManager(_ manager: WebSocketManager, didEncounterError error: Error)
}

/// Analytics delegate
public protocol AnalyticsDelegate: AnyObject {
    func trackEvent(_ event: AnalyticsEvent, properties: [String: Any])
}

/// Analytics event
public enum AnalyticsEvent: String {
    case webSocketConnected = "websocket_connected"
    case webSocketConnectionFailed = "websocket_connection_failed"
    case webSocketDisconnected = "websocket_disconnected"
    case webSocketDisconnectionError = "websocket_disconnection_error"
    case webSocketConnectionClosed = "websocket_connection_closed"
    case webSocketError = "websocket_error"
    case messageSent = "message_sent"
    case messageSendFailed = "message_send_failed"
    case messageReceived = "message_received"
    case messageDeserializationFailed = "message_deserialization_failed"
} 