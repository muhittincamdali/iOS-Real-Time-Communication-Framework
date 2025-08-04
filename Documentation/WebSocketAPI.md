# WebSocket API

## Overview

The WebSocket API provides a comprehensive implementation of the WebSocket protocol for real-time bidirectional communication. It supports both client and server connections with advanced features like automatic reconnection, message queuing, and heartbeat monitoring.

## Core Classes

### WebSocketClient

The main WebSocket client implementation.

```swift
public class WebSocketClient {
    // MARK: - Properties
    public var isConnected: Bool { get }
    public var connectionStatus: WebSocketConnectionStatus { get }
    public var url: URL? { get }
    public var configuration: WebSocketConfiguration { get }
    
    // MARK: - Initialization
    public init()
    public init(url: URL)
    public init(url: URL, configuration: WebSocketConfiguration)
    
    // MARK: - Configuration
    public func configure(_ configuration: WebSocketConfiguration)
    
    // MARK: - Connection Management
    public func connect() async throws
    public func connect(to url: URL) async throws
    public func disconnect()
    public func reconnect()
    
    // MARK: - Message Handling
    public func send(_ message: WebSocketMessage) async throws
    public func send(_ text: String) async throws
    public func send(_ data: Data) async throws
    
    // MARK: - Event Handling
    public func onConnect(_ handler: @escaping () -> Void)
    public func onDisconnect(_ handler: @escaping (WebSocketDisconnectReason) -> Void)
    public func onMessage(_ handler: @escaping (WebSocketMessage) -> Void)
    public func onError(_ handler: @escaping (WebSocketError) -> Void)
    public func onPing(_ handler: @escaping (Data?) -> Void)
    public func onPong(_ handler: @escaping (Data?) -> Void)
}
```

### WebSocketConfiguration

Configuration options for WebSocket connections.

```swift
public struct WebSocketConfiguration {
    // MARK: - Connection Settings
    public var url: URL?
    public var timeout: TimeInterval
    public var enableCompression: Bool
    public var compressionLevel: Int
    
    // MARK: - Reconnection Settings
    public var enableReconnection: Bool
    public var maxReconnectionAttempts: Int
    public var reconnectionDelay: TimeInterval
    public var reconnectionBackoffMultiplier: Double
    
    // MARK: - Heartbeat Settings
    public var enableHeartbeat: Bool
    public var heartbeatInterval: TimeInterval
    public var heartbeatTimeout: TimeInterval
    
    // MARK: - Security Settings
    public var enableSSL: Bool
    public var sslConfiguration: SSLConfiguration?
    public var customHeaders: [String: String]
    
    // MARK: - Message Settings
    public var maxMessageSize: Int
    public var enableMessageQueuing: Bool
    public var queueTimeout: TimeInterval
    
    // MARK: - Logging Settings
    public var enableLogging: Bool
    public var logLevel: WebSocketLogLevel
}
```

### WebSocketMessage

Represents a WebSocket message.

```swift
public struct WebSocketMessage {
    // MARK: - Properties
    public let type: WebSocketMessageType
    public let data: Data
    public let isComplete: Bool
    public let isBinary: Bool
    public let timestamp: Date
    
    // MARK: - Message Types
    public enum WebSocketMessageType {
        case text
        case binary
        case ping
        case pong
        case close
        case continuation
    }
    
    // MARK: - Initialization
    public init(type: WebSocketMessageType, data: Data)
    public init(text: String)
    public init(binary: Data)
    
    // MARK: - Convenience Methods
    public var text: String?
    public var binary: Data?
}
```

### WebSocketConnectionStatus

Connection status enumeration.

```swift
public enum WebSocketConnectionStatus {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case failed(WebSocketError)
}
```

### WebSocketDisconnectReason

Disconnect reason enumeration.

```swift
public enum WebSocketDisconnectReason {
    case normal
    case goingAway
    case protocolError
    case unsupportedData
    case noStatusReceived
    case abnormalClosure
    case invalidFramePayloadData
    case policyViolation
    case messageTooBig
    case internalServerError
    case tlsHandshake
    case custom(Int)
}
```

### WebSocketError

WebSocket-specific errors.

```swift
public enum WebSocketError: Error {
    case connectionFailed(String)
    case invalidURL(String)
    case timeout(String)
    case protocolError(String)
    case messageSendFailed(String)
    case messageReceiveFailed(String)
    case sslError(String)
    case networkError(String)
    case invalidState(String)
}
```

## Usage Examples

### Basic WebSocket Connection

```swift
import RealTimeCommunicationFramework

// Create WebSocket client
let webSocket = WebSocketClient()

// Configure WebSocket
let config = WebSocketConfiguration()
config.url = URL(string: "wss://api.company.com/ws")
config.enableReconnection = true
config.maxReconnectionAttempts = 5
config.enableHeartbeat = true
config.heartbeatInterval = 30
config.enableLogging = true

// Setup client
webSocket.configure(config)

// Connect to WebSocket
do {
    try await webSocket.connect()
    print("✅ WebSocket connected")
} catch {
    print("❌ WebSocket connection failed: \(error)")
}
```

### Message Handling

```swift
// Send text message
try await webSocket.send("Hello, WebSocket!")

// Send binary data
let imageData = UIImage(named: "avatar")?.jpegData(compressionQuality: 0.8)
if let data = imageData {
    try await webSocket.send(data)
}

// Send structured message
let message = WebSocketMessage(text: "Hello, World!")
try await webSocket.send(message)

// Listen for messages
webSocket.onMessage { message in
    switch message.type {
    case .text:
        if let text = message.text {
            print("📨 Received text: \(text)")
        }
    case .binary:
        if let data = message.binary {
            print("📨 Received binary data: \(data.count) bytes")
        }
    case .ping:
        print("🏓 Received ping")
    case .pong:
        print("🏓 Received pong")
    case .close:
        print("🔒 Connection closing")
    case .continuation:
        print("📨 Message continuation")
    }
}
```

### Connection Management

```swift
// Monitor connection status
webSocket.onConnect {
    print("✅ WebSocket connected")
}

webSocket.onDisconnect { reason in
    switch reason {
    case .normal:
        print("🔒 Normal disconnect")
    case .goingAway:
        print("🔒 Server going away")
    case .protocolError:
        print("❌ Protocol error")
    case .unsupportedData:
        print("❌ Unsupported data")
    case .noStatusReceived:
        print("❌ No status received")
    case .abnormalClosure:
        print("❌ Abnormal closure")
    case .invalidFramePayloadData:
        print("❌ Invalid frame payload")
    case .policyViolation:
        print("❌ Policy violation")
    case .messageTooBig:
        print("❌ Message too big")
    case .internalServerError:
        print("❌ Internal server error")
    case .tlsHandshake:
        print("❌ TLS handshake failed")
    case .custom(let code):
        print("❌ Custom error code: \(code)")
    }
}

// Handle errors
webSocket.onError { error in
    print("❌ WebSocket error: \(error)")
}
```

### Advanced Configuration

```swift
// Advanced configuration
let advancedConfig = WebSocketConfiguration()
advancedConfig.url = URL(string: "wss://api.company.com/ws")
advancedConfig.timeout = 30
advancedConfig.enableCompression = true
advancedConfig.compressionLevel = 6
advancedConfig.enableReconnection = true
advancedConfig.maxReconnectionAttempts = 10
advancedConfig.reconnectionDelay = 5
advancedConfig.reconnectionBackoffMultiplier = 1.5
advancedConfig.enableHeartbeat = true
advancedConfig.heartbeatInterval = 30
advancedConfig.heartbeatTimeout = 10
advancedConfig.enableSSL = true
advancedConfig.customHeaders = [
    "Authorization": "Bearer token123",
    "User-Agent": "iOS-Real-Time-Communication-Framework"
]
advancedConfig.maxMessageSize = 1024 * 1024 // 1MB
advancedConfig.enableMessageQueuing = true
advancedConfig.queueTimeout = 60
advancedConfig.enableLogging = true
advancedConfig.logLevel = .debug

webSocket.configure(advancedConfig)
```

### SSL Configuration

```swift
// SSL configuration
let sslConfig = SSLConfiguration()
sslConfig.enableCertificateValidation = true
sslConfig.enableHostnameValidation = true
sslConfig.allowedHostnames = ["api.company.com"]
sslConfig.certificatePinning = true
sslConfig.pinnedCertificates = ["sha256:..."]

let config = WebSocketConfiguration()
config.enableSSL = true
config.sslConfiguration = sslConfig

webSocket.configure(config)
```

### Heartbeat and Ping/Pong

```swift
// Handle ping/pong for connection health
webSocket.onPing { data in
    print("🏓 Received ping with data: \(data?.count ?? 0) bytes")
    // Automatically respond with pong
}

webSocket.onPong { data in
    print("🏓 Received pong with data: \(data?.count ?? 0) bytes")
}

// Manual ping
let pingData = "heartbeat".data(using: .utf8)
let pingMessage = WebSocketMessage(type: .ping, data: pingData ?? Data())
try await webSocket.send(pingMessage)
```

### Message Queuing

```swift
// Send message with queuing
let message = WebSocketMessage(text: "Important message")
try await webSocket.send(message)

// Messages are automatically queued when disconnected
// and sent when connection is restored
```

## Best Practices

1. **Always handle connection events** to provide user feedback
2. **Implement proper error handling** for robust communication
3. **Use heartbeat for connection health monitoring**
4. **Enable message queuing** for offline scenarios
5. **Configure appropriate timeouts** for your use case
6. **Use SSL for production** connections
7. **Monitor connection quality** and adjust settings
8. **Handle reconnection gracefully** for better UX

## Performance Considerations

- Use compression for text messages to reduce bandwidth
- Implement message size limits to prevent memory issues
- Use binary messages for large data transfers
- Configure appropriate heartbeat intervals
- Monitor connection quality and adjust settings
- Use connection pooling for multiple WebSocket connections
