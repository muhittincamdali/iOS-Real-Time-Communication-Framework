# Socket.IO API

## Overview

The Socket.IO API provides a complete Socket.IO client implementation for iOS applications. It supports all Socket.IO features including namespaces, rooms, events, acknowledgments, and binary data transmission.

## Core Classes

### SocketIOClient

The main Socket.IO client implementation.

```swift
public class SocketIOClient {
    // MARK: - Properties
    public var isConnected: Bool { get }
    public var connectionStatus: SocketIOConnectionStatus { get }
    public var serverURL: URL { get }
    public var namespace: String { get }
    public var configuration: SocketIOConfiguration { get }
    
    // MARK: - Initialization
    public init(serverURL: URL)
    public init(serverURL: URL, namespace: String)
    public init(serverURL: URL, configuration: SocketIOConfiguration)
    
    // MARK: - Configuration
    public func configure(_ configuration: SocketIOConfiguration)
    
    // MARK: - Connection Management
    public func connect() async throws
    public func disconnect()
    public func reconnect()
    
    // MARK: - Event Handling
    public func emit(_ event: String, data: Any...) async throws
    public func emit(_ event: String, data: Any..., completion: @escaping (Result<Void, SocketIOError>) -> Void)
    public func emitWithAck(_ event: String, data: Any...) async throws -> Any
    
    // MARK: - Event Listening
    public func on(_ event: String, callback: @escaping (SocketIOEvent) -> Void)
    public func off(_ event: String)
    public func offAll()
    
    // MARK: - Room Management
    public func joinRoom(_ room: String) async throws
    public func leaveRoom(_ room: String) async throws
    public func emitToRoom(_ room: String, event: String, data: Any...) async throws
    
    // MARK: - Status Events
    public func onConnect(_ handler: @escaping () -> Void)
    public func onDisconnect(_ handler: @escaping (SocketIODisconnectReason) -> Void)
    public func onError(_ handler: @escaping (SocketIOError) -> Void)
    public func onReconnect(_ handler: @escaping (Int) -> Void)
    public func onReconnectAttempt(_ handler: @escaping (Int) -> Void)
}
```

### SocketIOConfiguration

Configuration options for Socket.IO connections.

```swift
public struct SocketIOConfiguration {
    // MARK: - Connection Settings
    public var serverURL: URL
    public var namespace: String
    public var timeout: TimeInterval
    public var forceNew: Bool
    public var multiplex: Bool
    
    // MARK: - Transport Settings
    public var transports: [SocketIOTransport]
    public var upgrade: Bool
    public var rememberUpgrade: Bool
    
    // MARK: - Reconnection Settings
    public var enableReconnection: Bool
    public var reconnectionAttempts: Int
    public var reconnectionDelay: TimeInterval
    public var reconnectionDelayMax: TimeInterval
    public var maxReconnectionAttempts: Int
    public var randomizationFactor: Double
    
    // MARK: - Authentication Settings
    public var auth: [String: Any]?
    public var extraHeaders: [String: String]
    
    // MARK: - Binary Settings
    public var enableBinary: Bool
    public var binaryType: SocketIOBinaryType
    
    // MARK: - Logging Settings
    public var enableLogging: Bool
    public var logLevel: SocketIOLogLevel
}
```

### SocketIOEvent

Represents a Socket.IO event.

```swift
public struct SocketIOEvent {
    // MARK: - Properties
    public let event: String
    public let data: [Any]
    public let ack: SocketIOAckCallback?
    public let timestamp: Date
    public let source: SocketIOEventSource
    
    // MARK: - Event Source
    public enum SocketIOEventSource {
        case client
        case server
        case system
    }
    
    // MARK: - Convenience Methods
    public var firstData: Any?
    public var stringData: String?
    public var dictionaryData: [String: Any]?
    public var arrayData: [Any]?
}
```

### SocketIOConnectionStatus

Connection status enumeration.

```swift
public enum SocketIOConnectionStatus {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case failed(SocketIOError)
}
```

### SocketIOTransport

Supported transport protocols.

```swift
public enum SocketIOTransport: String {
    case websocket = "websocket"
    case polling = "polling"
}
```

### SocketIOBinaryType

Binary data types.

```swift
public enum SocketIOBinaryType {
    case blob
    case arrayBuffer
}
```

### SocketIOError

Socket.IO-specific errors.

```swift
public enum SocketIOError: Error {
    case connectionFailed(String)
    case invalidURL(String)
    case timeout(String)
    case protocolError(String)
    case eventEmissionFailed(String)
    case roomJoinFailed(String)
    case roomLeaveFailed(String)
    case authenticationFailed(String)
    case namespaceError(String)
    case transportError(String)
}
```

### SocketIODisconnectReason

Disconnect reason enumeration.

```swift
public enum SocketIODisconnectReason {
    case clientDisconnect
    case serverDisconnect
    case pingTimeout
    case transportClose
    case transportError
    case serverError
    case clientError
    case custom(String)
}
```

## Usage Examples

### Basic Socket.IO Connection

```swift
import RealTimeCommunicationFramework

// Create Socket.IO client
let socketIO = SocketIOClient(serverURL: URL(string: "https://api.company.com")!)

// Configure Socket.IO
let config = SocketIOConfiguration()
config.serverURL = URL(string: "https://api.company.com")!
config.namespace = "/chat"
config.enableReconnection = true
config.reconnectionAttempts = 5
config.reconnectionDelay = 1000
config.enableLogging = true
config.transports = [.websocket, .polling]

// Setup client
socketIO.configure(config)

// Connect to Socket.IO
do {
    try await socketIO.connect()
    print("✅ Socket.IO connected")
} catch {
    print("❌ Socket.IO connection failed: \(error)")
}
```

### Event Handling

```swift
// Listen for events
socketIO.on("message") { event in
    print("📨 Received message event")
    if let message = event.stringData {
        print("Message: \(message)")
    }
}

socketIO.on("user_joined") { event in
    print("👤 User joined event")
    if let userData = event.dictionaryData {
        print("User: \(userData)")
    }
}

socketIO.on("typing") { event in
    print("⌨️ Typing event")
    if let typingData = event.dictionaryData {
        print("Typing data: \(typingData)")
    }
}

// Emit events
try await socketIO.emit("message", data: "Hello, Socket.IO!")
try await socketIO.emit("join_room", data: "chat_room_123")
try await socketIO.emit("typing", data: ["room": "chat_room_123", "user": "user123"])
```

### Room Management

```swift
// Join room
try await socketIO.joinRoom("chat_room_123")

// Leave room
try await socketIO.leaveRoom("chat_room_123")

// Emit to specific room
try await socketIO.emitToRoom("chat_room_123", event: "message", data: "Hello, room!")
```

### Acknowledgment Handling

```swift
// Emit with acknowledgment
let ackData = try await socketIO.emitWithAck("private_message", data: "Secret message", "user456")
print("Message acknowledged: \(ackData)")

// Handle acknowledgment in callback
socketIO.emit("message", data: "Hello!") { result in
    switch result {
    case .success:
        print("✅ Message sent successfully")
    case .failure(let error):
        print("❌ Message failed: \(error)")
    }
}
```

### Connection Management

```swift
// Monitor connection status
socketIO.onConnect {
    print("✅ Socket.IO connected")
}

socketIO.onDisconnect { reason in
    switch reason {
    case .clientDisconnect:
        print("🔒 Client disconnected")
    case .serverDisconnect:
        print("🔒 Server disconnected")
    case .pingTimeout:
        print("⏰ Ping timeout")
    case .transportClose:
        print("🔒 Transport closed")
    case .transportError:
        print("❌ Transport error")
    case .serverError:
        print("❌ Server error")
    case .clientError:
        print("❌ Client error")
    case .custom(let reason):
        print("🔒 Custom disconnect: \(reason)")
    }
}

// Handle reconnection
socketIO.onReconnect { attempt in
    print("🔄 Reconnected on attempt \(attempt)")
}

socketIO.onReconnectAttempt { attempt in
    print("🔄 Reconnection attempt \(attempt)")
}

// Handle errors
socketIO.onError { error in
    print("❌ Socket.IO error: \(error)")
}
```

### Authentication

```swift
// Configure with authentication
let authConfig = SocketIOConfiguration()
authConfig.serverURL = URL(string: "https://api.company.com")!
authConfig.auth = [
    "token": "user_auth_token_123",
    "userId": "user123"
]
authConfig.extraHeaders = [
    "Authorization": "Bearer user_auth_token_123"
]

socketIO.configure(authConfig)
```

### Binary Data

```swift
// Configure for binary data
let binaryConfig = SocketIOConfiguration()
binaryConfig.enableBinary = true
binaryConfig.binaryType = .blob

socketIO.configure(binaryConfig)

// Send binary data
let imageData = UIImage(named: "avatar")?.jpegData(compressionQuality: 0.8)
if let data = imageData {
    try await socketIO.emit("image_upload", data: data)
}
```

### Advanced Configuration

```swift
// Advanced configuration
let advancedConfig = SocketIOConfiguration()
advancedConfig.serverURL = URL(string: "https://api.company.com")!
advancedConfig.namespace = "/chat"
advancedConfig.timeout = 20
advancedConfig.forceNew = false
advancedConfig.multiplex = true
advancedConfig.transports = [.websocket, .polling]
advancedConfig.upgrade = true
advancedConfig.rememberUpgrade = true
advancedConfig.enableReconnection = true
advancedConfig.reconnectionAttempts = 10
advancedConfig.reconnectionDelay = 1000
advancedConfig.reconnectionDelayMax = 5000
advancedConfig.maxReconnectionAttempts = 20
advancedConfig.randomizationFactor = 0.5
advancedConfig.auth = ["token": "auth_token"]
advancedConfig.extraHeaders = ["User-Agent": "iOS-SocketIO-Client"]
advancedConfig.enableBinary = true
advancedConfig.binaryType = .blob
advancedConfig.enableLogging = true
advancedConfig.logLevel = .debug

socketIO.configure(advancedConfig)
```

## Best Practices

1. **Always handle connection events** for proper state management
2. **Use acknowledgments** for critical messages
3. **Implement proper error handling** for robust communication
4. **Use rooms** for organized message routing
5. **Handle reconnection gracefully** for better UX
6. **Use appropriate transport protocols** for your use case
7. **Implement authentication** for secure connections
8. **Monitor connection health** with ping/pong

## Performance Considerations

- Use WebSocket transport for better performance
- Implement message queuing for offline scenarios
- Use binary data for large file transfers
- Configure appropriate reconnection settings
- Monitor connection quality and adjust settings
- Use namespaces for organized communication
- Implement proper cleanup on disconnect
