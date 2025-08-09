# Socket.IO API

<!-- TOC START -->
## Table of Contents
- [Socket.IO API](#socketio-api)
- [Overview](#overview)
- [Table of Contents](#table-of-contents)
- [SocketIOClient](#socketioclient)
  - [Initialization](#initialization)
  - [Configuration](#configuration)
  - [Connection Management](#connection-management)
  - [Event Handling](#event-handling)
  - [Room Management](#room-management)
  - [Status Monitoring](#status-monitoring)
- [SocketIOConfiguration](#socketioconfiguration)
  - [Properties](#properties)
  - [Example](#example)
- [SocketIOEvent](#socketioevent)
  - [Properties](#properties)
  - [Initialization](#initialization)
- [SocketIOEventHandler](#socketioeventhandler)
  - [Initialization](#initialization)
  - [Event Registration](#event-registration)
  - [Event Emission](#event-emission)
- [SocketIORoom](#socketioroom)
  - [Properties](#properties)
  - [Initialization](#initialization)
- [SocketIONamespace](#socketionamespace)
  - [Properties](#properties)
  - [Initialization](#initialization)
- [SocketIOError](#socketioerror)
  - [Error Types](#error-types)
  - [Properties](#properties)
  - [Example](#example)
- [SocketIOStatus](#socketiostatus)
  - [Status Types](#status-types)
  - [Example](#example)
- [SocketIOTransport](#socketiotransport)
  - [Transport Types](#transport-types)
- [Complete Example](#complete-example)
<!-- TOC END -->


## Overview

The Socket.IO API provides comprehensive Socket.IO client capabilities for iOS applications. This document covers all public interfaces, classes, and methods available in the Socket.IO module.

## Table of Contents

- [SocketIOClient](#socketioclient)
- [SocketIOConfiguration](#socketioconfiguration)
- [SocketIOEvent](#socketioevent)
- [SocketIOEventHandler](#socketioeventhandler)
- [SocketIORoom](#socketioroom)
- [SocketIONamespace](#socketionamespace)
- [SocketIOError](#socketioerror)
- [SocketIOStatus](#socketiostatus)

## SocketIOClient

The main Socket.IO client class that handles Socket.IO connections and communication.

### Initialization

```swift
let socketIOClient = SocketIOClient()
```

### Configuration

```swift
func configure(_ configuration: SocketIOConfiguration)
```

Configures the Socket.IO client with the specified configuration.

**Parameters:**
- `configuration`: The Socket.IO configuration object

**Example:**
```swift
let config = SocketIOConfiguration()
config.serverURL = "https://api.company.com"
config.enableReconnection = true
config.reconnectionAttempts = 5

socketIOClient.configure(config)
```

### Connection Management

```swift
func connect(completion: @escaping (Result<SocketIOConnection, SocketIOError>) -> Void)
```

Establishes a Socket.IO connection.

**Parameters:**
- `completion`: Completion handler called with the connection result

**Example:**
```swift
socketIOClient.connect { result in
    switch result {
    case .success(let connection):
        print("Connected: \(connection.id)")
    case .failure(let error):
        print("Connection failed: \(error)")
    }
}
```

```swift
func disconnect(completion: @escaping (Result<Void, SocketIOError>) -> Void)
```

Disconnects the Socket.IO connection.

**Parameters:**
- `completion`: Completion handler called with the disconnection result

**Example:**
```swift
socketIOClient.disconnect { result in
    switch result {
    case .success:
        print("Disconnected successfully")
    case .failure(let error):
        print("Disconnection failed: \(error)")
    }
}
```

### Event Handling

```swift
func emit(_ event: String, data: Any, completion: @escaping (Result<Void, SocketIOError>) -> Void)
```

Emits a Socket.IO event with data.

**Parameters:**
- `event`: The event name
- `data`: The event data
- `completion`: Completion handler called with the emit result

**Example:**
```swift
let messageData = ["text": "Hello, Socket.IO!", "timestamp": Date().timeIntervalSince1970]
socketIOClient.emit("message", data: messageData) { result in
    switch result {
    case .success:
        print("Event emitted successfully")
    case .failure(let error):
        print("Event emission failed: \(error)")
    }
}
```

```swift
func emitWithAck(_ event: String, data: Any, completion: @escaping (Result<Any, SocketIOError>) -> Void)
```

Emits a Socket.IO event with acknowledgment.

**Parameters:**
- `event`: The event name
- `data`: The event data
- `completion`: Completion handler called with the acknowledgment

**Example:**
```swift
socketIOClient.emitWithAck("message", data: ["text": "Hello!"]) { result in
    switch result {
    case .success(let response):
        print("Event acknowledged: \(response)")
    case .failure(let error):
        print("Event acknowledgment failed: \(error)")
    }
}
```

```swift
func on(_ event: String, handler: @escaping (Any) -> Void)
```

Sets up a handler for a specific event.

**Parameters:**
- `event`: The event name
- `handler`: Closure called when the event is received

**Example:**
```swift
socketIOClient.on("message") { data in
    if let messageData = data as? [String: Any],
       let text = messageData["text"] as? String {
        print("Received message: \(text)")
    }
}

socketIOClient.on("user_joined") { data in
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

### Room Management

```swift
func joinRoom(_ roomId: String, completion: @escaping (Result<Void, SocketIOError>) -> Void)
```

Joins a Socket.IO room.

**Parameters:**
- `roomId`: The room identifier
- `completion`: Completion handler called with the join result

**Example:**
```swift
socketIOClient.joinRoom("chat_room_123") { result in
    switch result {
    case .success:
        print("Joined room successfully")
    case .failure(let error):
        print("Join room failed: \(error)")
    }
}
```

```swift
func leaveRoom(_ roomId: String, completion: @escaping (Result<Void, SocketIOError>) -> Void)
```

Leaves a Socket.IO room.

**Parameters:**
- `roomId`: The room identifier
- `completion`: Completion handler called with the leave result

**Example:**
```swift
socketIOClient.leaveRoom("chat_room_123") { result in
    switch result {
    case .success:
        print("Left room successfully")
    case .failure(let error):
        print("Leave room failed: \(error)")
    }
}
```

```swift
func emitToRoom(_ event: String, data: Any, roomId: String, completion: @escaping (Result<Void, SocketIOError>) -> Void)
```

Emits an event to a specific room.

**Parameters:**
- `event`: The event name
- `data`: The event data
- `roomId`: The room identifier
- `completion`: Completion handler called with the emit result

**Example:**
```swift
socketIOClient.emitToRoom("message", data: ["text": "Hello room!"], roomId: "chat_room_123") { result in
    switch result {
    case .success:
        print("Event emitted to room")
    case .failure(let error):
        print("Room event emission failed: \(error)")
    }
}
```

### Status Monitoring

```swift
func onConnectionStatusChange(_ handler: @escaping (SocketIOStatus) -> Void)
```

Sets up a handler for connection status changes.

**Parameters:**
- `handler`: Closure called when connection status changes

**Example:**
```swift
socketIOClient.onConnectionStatusChange { status in
    switch status {
    case .connecting:
        print("Connecting to Socket.IO...")
    case .connected:
        print("Connected to Socket.IO")
    case .disconnected:
        print("Disconnected from Socket.IO")
    case .reconnecting:
        print("Reconnecting to Socket.IO...")
    case .failed(let error):
        print("Socket.IO connection failed: \(error)")
    }
}
```

```swift
func onError(_ handler: @escaping (SocketIOError) -> Void)
```

Sets up a handler for Socket.IO errors.

**Parameters:**
- `handler`: Closure called when an error occurs

**Example:**
```swift
socketIOClient.onError { error in
    print("Socket.IO error: \(error)")
}
```

## SocketIOConfiguration

Configuration class for Socket.IO client settings.

### Properties

```swift
var serverURL: String
```

The Socket.IO server URL.

```swift
var path: String
```

The Socket.IO path (default: "/socket.io/").

```swift
var port: Int
```

The Socket.IO server port.

```swift
var enableReconnection: Bool
```

Whether to enable automatic reconnection.

```swift
var reconnectionAttempts: Int
```

The maximum number of reconnection attempts.

```swift
var reconnectionDelay: TimeInterval
```

The delay between reconnection attempts in milliseconds.

```swift
var reconnectionDelayMax: TimeInterval
```

The maximum delay between reconnection attempts.

```swift
var timeout: TimeInterval
```

The connection timeout in milliseconds.

```swift
var transport: SocketIOTransport
```

The transport protocol to use.

```swift
var enableForceNew: Bool
```

Whether to force a new connection.

```swift
var enableMultiplex: Bool
```

Whether to enable connection multiplexing.

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

Custom headers to include in the connection.

```swift
var queryParameters: [String: String]
```

Query parameters to include in the connection.

```swift
var namespace: String
```

The Socket.IO namespace to connect to.

```swift
var enableCompression: Bool
```

Whether to enable message compression.

```swift
var enableBinaryMessages: Bool
```

Whether to enable binary message support.

```swift
var maxPayload: Int
```

The maximum payload size in bytes.

### Example

```swift
let config = SocketIOConfiguration()
config.serverURL = "https://api.company.com"
config.path = "/socket.io/"
config.port = 443
config.enableReconnection = true
config.reconnectionAttempts = 5
config.reconnectionDelay = 1000
config.reconnectionDelayMax = 5000
config.timeout = 20000
config.transport = .websocket
config.enableForceNew = true
config.enableMultiplex = false
config.enableSSL = true
config.enableCertificatePinning = true
config.customHeaders = [
    "Authorization": "Bearer token",
    "User-Agent": "iOS-SocketIO-Client"
]
config.queryParameters = [
    "client": "ios",
    "version": "2.1.0"
]
config.namespace = "/chat"
config.enableCompression = true
config.enableBinaryMessages = true
config.maxPayload = 1000000 // 1MB
```

## SocketIOEvent

Represents a Socket.IO event.

### Properties

```swift
var name: String
```

The event name.

```swift
var data: Any
```

The event data.

```swift
var timestamp: Date
```

The timestamp when the event was created.

```swift
var roomId: String?
```

The room identifier if the event is room-specific.

### Initialization

```swift
init(name: String, data: Any, roomId: String? = nil)
```

Creates a new Socket.IO event.

**Parameters:**
- `name`: The event name
- `data`: The event data
- `roomId`: Optional room identifier

**Example:**
```swift
let event = SocketIOEvent(
    name: "message",
    data: ["text": "Hello!"],
    roomId: "chat_room_123"
)
```

## SocketIOEventHandler

Handles Socket.IO events and provides event management capabilities.

### Initialization

```swift
let eventHandler = SocketIOEventHandler()
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

eventHandler.on("user_left") { data in
    if let userData = data as? [String: Any],
       let username = userData["username"] as? String {
        print("User left: \(username)")
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
func emit(_ event: String, data: Any, completion: @escaping (Result<Void, SocketIOError>) -> Void)
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

## SocketIORoom

Represents a Socket.IO room.

### Properties

```swift
var id: String
```

The room identifier.

```swift
var name: String
```

The room name.

```swift
var participants: [String]
```

The list of participant user IDs.

```swift
var isActive: Bool
```

Whether the room is currently active.

```swift
var createdAt: Date
```

When the room was created.

### Initialization

```swift
init(id: String, name: String)
```

Creates a new Socket.IO room.

**Parameters:**
- `id`: The room identifier
- `name`: The room name

**Example:**
```swift
let room = SocketIORoom(id: "chat_room_123", name: "General Chat")
```

## SocketIONamespace

Represents a Socket.IO namespace.

### Properties

```swift
var name: String
```

The namespace name.

```swift
var isConnected: Bool
```

Whether the namespace is connected.

```swift
var rooms: [SocketIORoom]
```

The rooms in this namespace.

### Initialization

```swift
init(name: String)
```

Creates a new Socket.IO namespace.

**Parameters:**
- `name`: The namespace name

**Example:**
```swift
let namespace = SocketIONamespace(name: "/chat")
```

## SocketIOError

Represents Socket.IO errors.

### Error Types

```swift
enum SocketIOError: Error {
    case connectionFailed(String)
    case authenticationFailed(String)
    case timeout
    case serverError(Int, String)
    case transportError(Error)
    case eventNotFound(String)
    case invalidEventData(String, Any)
    case eventTimeout(String)
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
socketIOClient.onError { error in
    switch error {
    case .connectionFailed(let reason):
        print("Connection failed: \(reason)")
    case .authenticationFailed(let reason):
        print("Authentication failed: \(reason)")
    case .timeout:
        print("Connection timeout")
    case .serverError(let code, let message):
        print("Server error \(code): \(message)")
    case .transportError(let underlyingError):
        print("Transport error: \(underlyingError)")
    case .eventNotFound(let eventName):
        print("Event not found: \(eventName)")
    case .invalidEventData(let eventName, let data):
        print("Invalid data for event \(eventName): \(data)")
    case .eventTimeout(let eventName):
        print("Event timeout: \(eventName)")
    }
}
```

## SocketIOStatus

Represents Socket.IO connection status.

### Status Types

```swift
enum SocketIOStatus {
    case connecting
    case connected
    case disconnected
    case reconnecting
    case failed(SocketIOError)
}
```

### Example

```swift
socketIOClient.onConnectionStatusChange { status in
    switch status {
    case .connecting:
        print("🔄 Connecting to Socket.IO...")
    case .connected:
        print("✅ Connected to Socket.IO")
    case .disconnected:
        print("❌ Disconnected from Socket.IO")
    case .reconnecting:
        print("🔄 Reconnecting to Socket.IO...")
    case .failed(let error):
        print("❌ Socket.IO connection failed: \(error)")
    }
}
```

## SocketIOTransport

Represents Socket.IO transport protocols.

### Transport Types

```swift
enum SocketIOTransport {
    case websocket
    case polling
    case auto
}
```

## Complete Example

```swift
import RealTimeCommunication

class SocketIOManager: ObservableObject {
    private let socketIOClient = SocketIOClient()
    @Published var isConnected = false
    @Published var messages: [ChatMessage] = []
    @Published var typingUsers: Set<String> = []
    
    init() {
        setupSocketIO()
    }
    
    private func setupSocketIO() {
        let config = SocketIOConfiguration()
        config.serverURL = "https://api.company.com"
        config.enableReconnection = true
        config.reconnectionAttempts = 5
        config.namespace = "/chat"
        
        socketIOClient.configure(config)
        
        // Monitor connection status
        socketIOClient.onConnectionStatusChange { [weak self] status in
            DispatchQueue.main.async {
                self?.isConnected = (status == .connected)
            }
        }
        
        // Handle chat messages
        socketIOClient.on("message") { [weak self] data in
            if let messageData = data as? [String: Any],
               let text = messageData["text"] as? String,
               let sender = messageData["sender"] as? String {
                let message = ChatMessage(text: text, sender: sender, timestamp: Date())
                DispatchQueue.main.async {
                    self?.messages.append(message)
                }
            }
        }
        
        // Handle typing indicators
        socketIOClient.on("typing_started") { [weak self] data in
            if let userData = data as? [String: Any],
               let username = userData["username"] as? String {
                DispatchQueue.main.async {
                    self?.typingUsers.insert(username)
                }
            }
        }
        
        socketIOClient.on("typing_stopped") { [weak self] data in
            if let userData = data as? [String: Any],
               let username = userData["username"] as? String {
                DispatchQueue.main.async {
                    self?.typingUsers.remove(username)
                }
            }
        }
        
        // Handle errors
        socketIOClient.onError { error in
            print("Socket.IO error: \(error)")
        }
    }
    
    func connect() {
        socketIOClient.connect { result in
            switch result {
            case .success(let connection):
                print("✅ Connected: \(connection.id)")
            case .failure(let error):
                print("❌ Connection failed: \(error)")
            }
        }
    }
    
    func joinRoom(_ roomId: String) {
        socketIOClient.joinRoom(roomId) { result in
            switch result {
            case .success:
                print("✅ Joined room: \(roomId)")
            case .failure(let error):
                print("❌ Join room failed: \(error)")
            }
        }
    }
    
    func sendMessage(_ text: String, to roomId: String) {
        let messageData = [
            "text": text,
            "roomId": roomId,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        socketIOClient.emit("message", data: messageData) { result in
            switch result {
            case .success:
                print("✅ Message sent")
            case .failure(let error):
                print("❌ Message failed: \(error)")
            }
        }
    }
    
    func startTyping(in roomId: String) {
        socketIOClient.emit("typing_started", data: ["roomId": roomId]) { result in
            switch result {
            case .success:
                print("✅ Typing started")
            case .failure(let error):
                print("❌ Typing start failed: \(error)")
            }
        }
    }
    
    func stopTyping(in roomId: String) {
        socketIOClient.emit("typing_stopped", data: ["roomId": roomId]) { result in
            switch result {
            case .success:
                print("✅ Typing stopped")
            case .failure(let error):
                print("❌ Typing stop failed: \(error)")
            }
        }
    }
    
    func disconnect() {
        socketIOClient.disconnect { result in
            switch result {
            case .success:
                print("✅ Disconnected")
            case .failure(let error):
                print("❌ Disconnection failed: \(error)")
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let sender: String
    let timestamp: Date
}

struct SocketIOChatView: View {
    @StateObject private var socketIOManager = SocketIOManager()
    @State private var messageText = ""
    @State private var roomId = "general"
    
    var body: some View {
        VStack {
            // Connection status
            HStack {
                Circle()
                    .fill(socketIOManager.isConnected ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                Text(socketIOManager.isConnected ? "Connected" : "Disconnected")
            }
            .padding()
            
            // Typing indicators
            if !socketIOManager.typingUsers.isEmpty {
                HStack {
                    Text("\(socketIOManager.typingUsers.joined(separator: ", ")) typing...")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            // Messages
            ScrollView {
                LazyVStack {
                    ForEach(socketIOManager.messages) { message in
                        VStack(alignment: .leading) {
                            Text(message.sender)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(message.text)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // Message input
            HStack {
                TextField("Enter message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: messageText) { _ in
                        if !messageText.isEmpty {
                            socketIOManager.startTyping(in: roomId)
                        } else {
                            socketIOManager.stopTyping(in: roomId)
                        }
                    }
                
                Button("Send") {
                    socketIOManager.sendMessage(messageText, to: roomId)
                    messageText = ""
                    socketIOManager.stopTyping(in: roomId)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .onAppear {
            socketIOManager.connect()
            socketIOManager.joinRoom(roomId)
        }
        .onDisappear {
            socketIOManager.disconnect()
        }
    }
}
```

This comprehensive API documentation covers all aspects of the Socket.IO module in the iOS Real-Time Communication Framework. For more examples and advanced usage, refer to the Socket.IO Guide and other documentation.
