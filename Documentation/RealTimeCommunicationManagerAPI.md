# Real-Time Communication Manager API

## Overview

The `RealTimeCommunicationManager` is the core component of the iOS Real-Time Communication Framework. It provides a unified interface for managing multiple communication protocols including WebSocket, Socket.IO, Firebase, and push notifications.

## Core Classes

### RealTimeCommunicationManager

The main manager class that orchestrates all communication protocols.

```swift
public class RealTimeCommunicationManager {
    // MARK: - Properties
    public var isConnected: Bool { get }
    public var connectionStatus: ConnectionStatus { get }
    public var activeProtocols: Set<CommunicationProtocol> { get }
    
    // MARK: - Initialization
    public init()
    
    // MARK: - Configuration
    public func configure(_ configuration: RealTimeCommunicationConfiguration)
    public func start(with configuration: RealTimeCommunicationConfiguration)
    public func stop()
    
    // MARK: - Protocol Management
    public func enableProtocol(_ protocol: CommunicationProtocol)
    public func disableProtocol(_ protocol: CommunicationProtocol)
    public func isProtocolEnabled(_ protocol: CommunicationProtocol) -> Bool
    
    // MARK: - Connection Management
    public func connect() async throws
    public func disconnect()
    public func reconnect()
    
    // MARK: - Message Handling
    public func sendMessage(_ message: CommunicationMessage) async throws
    public func broadcastMessage(_ message: CommunicationMessage) async throws
    
    // MARK: - Event Handling
    public func onMessageReceived(_ handler: @escaping (CommunicationMessage) -> Void)
    public func onConnectionStatusChanged(_ handler: @escaping (ConnectionStatus) -> Void)
    public func onError(_ handler: @escaping (CommunicationError) -> Void)
}
```

### RealTimeCommunicationConfiguration

Configuration class for the communication manager.

```swift
public struct RealTimeCommunicationConfiguration {
    // MARK: - Protocol Settings
    public var enableWebSocket: Bool
    public var enableSocketIO: Bool
    public var enableFirebase: Bool
    public var enablePushNotifications: Bool
    
    // MARK: - Connection Settings
    public var connectionTimeout: TimeInterval
    public var maxReconnectionAttempts: Int
    public var enableHeartbeat: Bool
    public var heartbeatInterval: TimeInterval
    
    // MARK: - Security Settings
    public var enableEncryption: Bool
    public var enableAuthentication: Bool
    public var enableSSL: Bool
    
    // MARK: - Logging Settings
    public var enableLogging: Bool
    public var logLevel: LogLevel
    
    // MARK: - Analytics Settings
    public var enableAnalytics: Bool
    public var analyticsEndpoint: String?
}
```

### CommunicationMessage

Represents a communication message across all protocols.

```swift
public struct CommunicationMessage {
    // MARK: - Properties
    public let id: String
    public let type: MessageType
    public let data: Any
    public let sender: String?
    public let recipient: String?
    public let timestamp: Date
    public let metadata: [String: Any]
    
    // MARK: - Message Types
    public enum MessageType {
        case text
        case binary
        case json
        case custom(String)
    }
    
    // MARK: - Initialization
    public init(type: MessageType, data: Any, sender: String? = nil, recipient: String? = nil)
}
```

### ConnectionStatus

Represents the current connection status.

```swift
public enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case failed(Error)
}
```

### CommunicationProtocol

Supported communication protocols.

```swift
public enum CommunicationProtocol {
    case webSocket
    case socketIO
    case firebase
    case pushNotifications
}
```

### CommunicationError

Communication-related errors.

```swift
public enum CommunicationError: Error {
    case connectionFailed(String)
    case messageSendFailed(String)
    case protocolNotEnabled(CommunicationProtocol)
    case invalidConfiguration(String)
    case authenticationFailed(String)
    case timeout(String)
    case networkError(String)
}
```

## Usage Examples

### Basic Setup

```swift
import RealTimeCommunicationFramework

// Initialize manager
let manager = RealTimeCommunicationManager()

// Configure settings
let config = RealTimeCommunicationConfiguration()
config.enableWebSocket = true
config.enableSocketIO = true
config.enableFirebase = true
config.enablePushNotifications = true
config.connectionTimeout = 30
config.maxReconnectionAttempts = 5
config.enableHeartbeat = true
config.enableEncryption = true
config.enableLogging = true

// Start communication
manager.configure(config)
try await manager.start(with: config)
```

### Message Handling

```swift
// Send message
let message = CommunicationMessage(
    type: .text,
    data: "Hello, World!",
    sender: "user123",
    recipient: "user456"
)

try await manager.sendMessage(message)

// Listen for messages
manager.onMessageReceived { message in
    print("Received message: \(message.data)")
    print("From: \(message.sender ?? "Unknown")")
    print("Type: \(message.type)")
}
```

### Connection Management

```swift
// Monitor connection status
manager.onConnectionStatusChanged { status in
    switch status {
    case .connected:
        print("✅ Connected to all protocols")
    case .connecting:
        print("🔄 Connecting...")
    case .disconnected:
        print("❌ Disconnected")
    case .reconnecting:
        print("🔄 Reconnecting...")
    case .failed(let error):
        print("❌ Connection failed: \(error)")
    }
}

// Handle errors
manager.onError { error in
    print("❌ Communication error: \(error)")
}
```

### Protocol Management

```swift
// Enable specific protocols
manager.enableProtocol(.webSocket)
manager.enableProtocol(.socketIO)

// Check protocol status
if manager.isProtocolEnabled(.webSocket) {
    print("WebSocket is enabled")
}

// Disable protocol
manager.disableProtocol(.firebase)
```

## Advanced Features

### Message Broadcasting

```swift
// Broadcast message to all connected clients
let broadcastMessage = CommunicationMessage(
    type: .json,
    data: ["announcement": "Server maintenance in 5 minutes"],
    sender: "system"
)

try await manager.broadcastMessage(broadcastMessage)
```

### Custom Message Types

```swift
// Create custom message type
let customMessage = CommunicationMessage(
    type: .custom("user_status"),
    data: ["status": "online", "lastSeen": Date()],
    sender: "user123"
)

try await manager.sendMessage(customMessage)
```

### Error Handling

```swift
do {
    try await manager.sendMessage(message)
} catch CommunicationError.connectionFailed(let reason) {
    print("Connection failed: \(reason)")
} catch CommunicationError.messageSendFailed(let reason) {
    print("Message send failed: \(reason)")
} catch CommunicationError.protocolNotEnabled(let protocol) {
    print("Protocol \(protocol) is not enabled")
} catch {
    print("Unexpected error: \(error)")
}
```

## Best Practices

1. **Always handle connection status changes** to provide user feedback
2. **Implement proper error handling** for robust communication
3. **Use appropriate message types** for different data formats
4. **Enable logging in development** for debugging
5. **Configure security settings** for production use
6. **Monitor connection health** with heartbeat
7. **Handle reconnection gracefully** for better user experience

## Performance Considerations

- Use binary messages for large data transfers
- Implement message queuing for offline scenarios
- Enable compression for bandwidth optimization
- Monitor connection quality and adjust settings accordingly
- Use appropriate timeout values for your network conditions
