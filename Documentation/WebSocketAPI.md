# WebSocket API

## Overview

The WebSocket API provides comprehensive real-time communication capabilities for iOS applications. This document covers all public interfaces, classes, and methods available in the WebSocket module.

## Table of Contents

- [WebSocketClient](#websocketclient)
- [WebSocketConfiguration](#websocketconfiguration)
- [WebSocketMessage](#websocketmessage)
- [WebSocketConnection](#websocketconnection)
- [WebSocketConnectionManager](#websocketconnectionmanager)
- [WebSocketEventHandler](#websocketeventhandler)
- [WebSocketError](#websocketerror)
- [WebSocketStatus](#websocketstatus)

## WebSocketClient

The main WebSocket client class that handles WebSocket connections and communication.

### Initialization

```swift
let webSocketClient = WebSocketClient()
```

### Configuration

```swift
func configure(_ configuration: WebSocketConfiguration)
```

Configures the WebSocket client with the specified configuration.

**Parameters:**
- `configuration`: The WebSocket configuration object

**Example:**
```swift
let config = WebSocketConfiguration()
config.url = "wss://api.company.com/ws"
config.enableReconnection = true
config.heartbeatInterval = 30

webSocketClient.configure(config)
```

### Connection Management

```swift
func connect(completion: @escaping (Result<WebSocketConnection, WebSocketError>) -> Void)
```

Establishes a WebSocket connection.

**Parameters:**
- `completion`: Completion handler called with the connection result

**Example:**
```swift
webSocketClient.connect { result in
    switch result {
    case .success(let connection):
        print("Connected: \(connection.id)")
    case .failure(let error):
        print("Connection failed: \(error)")
    }
}
```

```swift
func disconnect(completion: @escaping (Result<Void, WebSocketError>) -> Void)
```

Disconnects the WebSocket connection.

**Parameters:**
- `completion`: Completion handler called with the disconnection result

**Example:**
```swift
webSocketClient.disconnect { result in
    switch result {
    case .success:
        print("Disconnected successfully")
    case .failure(let error):
        print("Disconnection failed: \(error)")
    }
}
```

### Message Handling

```swift
func send(_ message: WebSocketMessage, completion: @escaping (Result<Void, WebSocketError>) -> Void)
```

Sends a WebSocket message.

**Parameters:**
- `message`: The message to send
- `completion`: Completion handler called with the send result

**Example:**
```swift
let message = WebSocketMessage(type: .text, data: "Hello, WebSocket!")
webSocketClient.send(message) { result in
    switch result {
    case .success:
        print("Message sent successfully")
    case .failure(let error):
        print("Message send failed: \(error)")
    }
}
```

```swift
func onMessage(_ handler: @escaping (WebSocketMessage) -> Void)
```

Sets up a handler for incoming messages.

**Parameters:**
- `handler`: Closure called when a message is received

**Example:**
```swift
webSocketClient.onMessage { message in
    switch message.type {
    case .text:
        if let text = String(data: message.data, encoding: .utf8) {
            print("Received text: \(text)")
        }
    case .binary:
        print("Received binary data: \(message.data.count) bytes")
    default:
        break
    }
}
```

### Event Handling

```swift
func onConnectionStatusChange(_ handler: @escaping (WebSocketStatus) -> Void)
```

Sets up a handler for connection status changes.

**Parameters:**
- `handler`: Closure called when connection status changes

**Example:**
```swift
webSocketClient.onConnectionStatusChange { status in
    switch status {
    case .connecting:
        print("Connecting...")
    case .connected:
        print("Connected")
    case .disconnected:
        print("Disconnected")
    case .reconnecting:
        print("Reconnecting...")
    case .failed(let error):
        print("Connection failed: \(error)")
    }
}
```

```swift
func onError(_ handler: @escaping (WebSocketError) -> Void)
```

Sets up a handler for WebSocket errors.

**Parameters:**
- `handler`: Closure called when an error occurs

**Example:**
```swift
webSocketClient.onError { error in
    print("WebSocket error: \(error)")
}
```

## WebSocketConfiguration

Configuration class for WebSocket client settings.

### Properties

```swift
var url: String
```

The WebSocket server URL.

```swift
var enableReconnection: Bool
```

Whether to enable automatic reconnection.

```swift
var heartbeatInterval: TimeInterval
```

The heartbeat interval in seconds.

```swift
var maxReconnectionAttempts: Int
```

The maximum number of reconnection attempts.

```swift
var reconnectionDelay: TimeInterval
```

The delay between reconnection attempts.

```swift
var enableSSL: Bool
```

Whether to enable SSL/TLS encryption.

```swift
var enableCertificatePinning: Bool
```

Whether to enable certificate pinning.

```swift
var customHeaders: [String: String]
```

Custom headers to include in the WebSocket handshake.

```swift
var enableCompression: Bool
```

Whether to enable message compression.

```swift
var maxMessageSize: Int
```

The maximum message size in bytes.

### Example

```swift
let config = WebSocketConfiguration()
config.url = "wss://api.company.com/ws"
config.enableReconnection = true
config.heartbeatInterval = 30
config.maxReconnectionAttempts = 5
config.reconnectionDelay = 1000
config.enableSSL = true
config.enableCertificatePinning = true
config.customHeaders = [
    "Authorization": "Bearer token",
    "User-Agent": "iOS-WebSocket-Client"
]
config.enableCompression = true
config.maxMessageSize = 1024 * 1024 // 1MB
```

## WebSocketMessage

Represents a WebSocket message.

### Properties

```swift
var type: WebSocketMessageType
```

The type of the message.

```swift
var data: Data
```

The message data.

```swift
var timestamp: Date
```

The timestamp when the message was created.

### Initialization

```swift
init(type: WebSocketMessageType, data: Data)
```

Creates a new WebSocket message.

**Parameters:**
- `type`: The message type
- `data`: The message data

**Example:**
```swift
let textData = "Hello, WebSocket!".data(using: .utf8)!
let message = WebSocketMessage(type: .text, data: textData)
```

### Message Types

```swift
enum WebSocketMessageType {
    case text
    case binary
    case ping
    case pong
    case close
}
```

## WebSocketConnection

Represents a WebSocket connection.

### Properties

```swift
var id: String
```

The unique connection identifier.

```swift
var url: String
```

The connection URL.

```swift
var status: WebSocketStatus
```

The current connection status.

```swift
var isConnected: Bool
```

Whether the connection is currently connected.

```swift
var connectionTime: Date
```

When the connection was established.

```swift
var lastActivity: Date
```

When the last activity occurred.

## WebSocketConnectionManager

Manages multiple WebSocket connections.

### Initialization

```swift
let connectionManager = WebSocketConnectionManager()
```

### Connection Management

```swift
func createConnection(to url: String, configuration: WebSocketConfiguration) -> WebSocketClient
```

Creates a new WebSocket connection.

**Parameters:**
- `url`: The WebSocket server URL
- `configuration`: The connection configuration

**Returns:**
- A configured WebSocket client

**Example:**
```swift
let config = WebSocketConfiguration()
config.enableReconnection = true

let client = connectionManager.createConnection(
    to: "wss://api.company.com/ws",
    configuration: config
)
```

```swift
func getConnection(id: String) -> WebSocketClient?
```

Gets a connection by ID.

**Parameters:**
- `id`: The connection ID

**Returns:**
- The WebSocket client if found, nil otherwise

```swift
func closeConnection(id: String, completion: @escaping (Result<Void, WebSocketError>) -> Void)
```

Closes a specific connection.

**Parameters:**
- `id`: The connection ID
- `completion`: Completion handler

```swift
func closeAllConnections(completion: @escaping (Result<Void, WebSocketError>) -> Void)
```

Closes all connections.

**Parameters:**
- `completion`: Completion handler

### Connection Monitoring

```swift
func getActiveConnections() -> [WebSocketClient]
```

Gets all active connections.

**Returns:**
- Array of active WebSocket clients

```swift
func getConnectionStatus(id: String) -> WebSocketStatus?
```

Gets the status of a specific connection.

**Parameters:**
- `id`: The connection ID

**Returns:**
- The connection status if found, nil otherwise

## WebSocketEventHandler

Handles WebSocket events and messages.

### Initialization

```swift
let eventHandler = WebSocketEventHandler()
```

### Event Registration

```swift
func on(_ event: String, handler: @escaping (Any) -> Void)
```

Registers a handler for a specific event.

**Parameters:**
- `event`: The event name
- `handler`: The event handler

**Example:**
```swift
eventHandler.on("message") { data in
    print("Received message: \(data)")
}

eventHandler.on("user_joined") { data in
    if let userData = data as? [String: Any],
       let username = userData["username"] as? String {
        print("User joined: \(username)")
    }
}
```

```swift
func off(_ event: String)
```

Removes a handler for a specific event.

**Parameters:**
- `event`: The event name

```swift
func offAll()
```

Removes all event handlers.

### Event Emission

```swift
func emit(_ event: String, data: Any, completion: @escaping (Result<Void, WebSocketError>) -> Void)
```

Emits an event with data.

**Parameters:**
- `event`: The event name
- `data`: The event data
- `completion`: Completion handler

**Example:**
```swift
let messageData = ["text": "Hello!", "timestamp": Date().timeIntervalSince1970]
eventHandler.emit("message", data: messageData) { result in
    switch result {
    case .success:
        print("Event emitted successfully")
    case .failure(let error):
        print("Event emission failed: \(error)")
    }
}
```

## WebSocketError

Represents WebSocket errors.

### Error Types

```swift
enum WebSocketError: Error {
    case connectionFailed(String)
    case authenticationFailed(String)
    case timeout
    case networkError(Error)
    case sslError(Error)
    case messageTooLarge(Int)
    case invalidMessageFormat
    case encodingError(Error)
}
```

### Properties

```swift
var localizedDescription: String
```

A human-readable description of the error.

```swift
var code: Int
```

The error code.

### Example

```swift
webSocketClient.onError { error in
    switch error {
    case .connectionFailed(let reason):
        print("Connection failed: \(reason)")
    case .authenticationFailed(let reason):
        print("Authentication failed: \(reason)")
    case .timeout:
        print("Connection timeout")
    case .networkError(let underlyingError):
        print("Network error: \(underlyingError)")
    case .sslError(let sslError):
        print("SSL error: \(sslError)")
    case .messageTooLarge(let size):
        print("Message too large: \(size) bytes")
    case .invalidMessageFormat:
        print("Invalid message format")
    case .encodingError(let encodingError):
        print("Encoding error: \(encodingError)")
    }
}
```

## WebSocketStatus

Represents WebSocket connection status.

### Status Types

```swift
enum WebSocketStatus {
    case connecting
    case connected
    case disconnected
    case reconnecting
    case failed(WebSocketError)
}
```

### Example

```swift
webSocketClient.onConnectionStatusChange { status in
    switch status {
    case .connecting:
        print("🔄 Connecting...")
    case .connected:
        print("✅ Connected")
    case .disconnected:
        print("❌ Disconnected")
    case .reconnecting:
        print("🔄 Reconnecting...")
    case .failed(let error):
        print("❌ Connection failed: \(error)")
    }
}
```

## Complete Example

```swift
import RealTimeCommunication

class WebSocketManager: ObservableObject {
    private let webSocketClient = WebSocketClient()
    @Published var isConnected = false
    @Published var messages: [String] = []
    
    init() {
        setupWebSocket()
    }
    
    private func setupWebSocket() {
        let config = WebSocketConfiguration()
        config.url = "wss://api.company.com/ws"
        config.enableReconnection = true
        config.heartbeatInterval = 30
        config.maxReconnectionAttempts = 5
        
        webSocketClient.configure(config)
        
        // Monitor connection status
        webSocketClient.onConnectionStatusChange { [weak self] status in
            DispatchQueue.main.async {
                self?.isConnected = (status == .connected)
            }
        }
        
        // Handle incoming messages
        webSocketClient.onMessage { [weak self] message in
            if let text = String(data: message.data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self?.messages.append(text)
                }
            }
        }
        
        // Handle errors
        webSocketClient.onError { error in
            print("WebSocket error: \(error)")
        }
    }
    
    func connect() {
        webSocketClient.connect { result in
            switch result {
            case .success(let connection):
                print("✅ Connected: \(connection.id)")
            case .failure(let error):
                print("❌ Connection failed: \(error)")
            }
        }
    }
    
    func sendMessage(_ text: String) {
        let message = WebSocketMessage(type: .text, data: text.data(using: .utf8)!)
        webSocketClient.send(message) { result in
            switch result {
            case .success:
                print("✅ Message sent")
            case .failure(let error):
                print("❌ Message failed: \(error)")
            }
        }
    }
    
    func disconnect() {
        webSocketClient.disconnect { result in
            switch result {
            case .success:
                print("✅ Disconnected")
            case .failure(let error):
                print("❌ Disconnection failed: \(error)")
            }
        }
    }
}

struct WebSocketView: View {
    @StateObject private var webSocketManager = WebSocketManager()
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            // Connection status
            HStack {
                Circle()
                    .fill(webSocketManager.isConnected ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                Text(webSocketManager.isConnected ? "Connected" : "Disconnected")
            }
            .padding()
            
            // Messages
            ScrollView {
                LazyVStack {
                    ForEach(webSocketManager.messages, id: \.self) { message in
                        Text(message)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            
            // Message input
            HStack {
                TextField("Enter message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Send") {
                    webSocketManager.sendMessage(messageText)
                    messageText = ""
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .onAppear {
            webSocketManager.connect()
        }
        .onDisappear {
            webSocketManager.disconnect()
        }
    }
}
```

This comprehensive API documentation covers all aspects of the WebSocket module in the iOS Real-Time Communication Framework. For more examples and advanced usage, refer to the WebSocket Guide and other documentation.
