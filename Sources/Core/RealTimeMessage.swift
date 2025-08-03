import Foundation

/// Represents a real-time message in the communication system
public struct RealTimeMessage: Codable {
    public let id: UUID
    public let type: MessageType
    public let data: Data
    public let timestamp: Date
    public let sender: String?
    public let recipient: String?
    public let metadata: [String: String]
    
    public init(
        id: UUID = UUID(),
        type: MessageType,
        data: Data,
        timestamp: Date = Date(),
        sender: String? = nil,
        recipient: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.data = data
        self.timestamp = timestamp
        self.sender = sender
        self.recipient = recipient
        self.metadata = metadata
    }
}

/// Message types supported by the framework
public enum MessageType: String, Codable, CaseIterable {
    case text = "text"
    case binary = "binary"
    case json = "json"
    case heartbeat = "heartbeat"
    case notification = "notification"
    case command = "command"
    case response = "response"
    case error = "error"
}

/// Connection result
public struct ConnectionResult {
    public let status: ConnectionStatus
    public let serverURL: String
    public let connectionTime: Date
    public let sessionID: String
    
    public init(
        status: ConnectionStatus,
        serverURL: String,
        connectionTime: Date,
        sessionID: String
    ) {
        self.status = status
        self.serverURL = serverURL
        self.connectionTime = connectionTime
        self.sessionID = sessionID
    }
}

/// Disconnection result
public struct DisconnectionResult {
    public let status: ConnectionStatus
    public let sessionDuration: TimeInterval
    public let error: Error?
    
    public init(
        status: ConnectionStatus,
        sessionDuration: TimeInterval,
        error: Error? = nil
    ) {
        self.status = status
        self.sessionDuration = sessionDuration
        self.error = error
    }
}

/// Connection error types
public enum ConnectionError: Error, LocalizedError {
    case networkUnavailable
    case authenticationFailed
    case connectionFailed(Error)
    case disconnectionFailed(Error)
    case timeout
    case serverUnreachable
    
    public var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network is unavailable"
        case .authenticationFailed:
            return "Authentication failed"
        case .connectionFailed(let error):
            return "Connection failed: \(error.localizedDescription)"
        case .disconnectionFailed(let error):
            return "Disconnection failed: \(error.localizedDescription)"
        case .timeout:
            return "Connection timeout"
        case .serverUnreachable:
            return "Server is unreachable"
        }
    }
}

/// Message error types
public enum MessageError: Error, LocalizedError {
    case sendFailed(Error)
    case receiveFailed(Error)
    case serializationFailed(Error)
    case deserializationFailed(Error)
    case connectionNotAvailable
    case queueFull
    case invalidMessage
    
    public var errorDescription: String? {
        switch self {
        case .sendFailed(let error):
            return "Message send failed: \(error.localizedDescription)"
        case .receiveFailed(let error):
            return "Message receive failed: \(error.localizedDescription)"
        case .serializationFailed(let error):
            return "Message serialization failed: \(error.localizedDescription)"
        case .deserializationFailed(let error):
            return "Message deserialization failed: \(error.localizedDescription)"
        case .connectionNotAvailable:
            return "Connection not available"
        case .queueFull:
            return "Message queue is full"
        case .invalidMessage:
            return "Invalid message format"
        }
    }
}

/// WebSocket connection interface
public protocol WebSocketConnection {
    var isConnected: Bool { get }
    var onMessage: ((Data) -> Void)? { get set }
    var onClose: (() -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    
    func send(data: Data) throws
    func close() async throws
}

/// WebSocket client interface
public protocol WebSocketClient {
    func connect(to url: URL) async throws -> WebSocketConnection
} 