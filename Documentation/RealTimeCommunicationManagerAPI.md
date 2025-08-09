# RealTimeCommunicationManager API

<!-- TOC START -->
## Table of Contents
- [RealTimeCommunicationManager API](#realtimecommunicationmanager-api)
- [Overview](#overview)
- [Table of Contents](#table-of-contents)
- [RealTimeCommunicationManager](#realtimecommunicationmanager)
  - [Initialization](#initialization)
  - [Configuration](#configuration)
  - [Connection Management](#connection-management)
  - [Message Handling](#message-handling)
  - [Message Reception](#message-reception)
  - [Connection Status](#connection-status)
  - [Room Management](#room-management)
  - [Push Notifications](#push-notifications)
  - [Message Queue](#message-queue)
- [CommunicationConfiguration](#communicationconfiguration)
  - [Properties](#properties)
  - [Example](#example)
- [CommunicationConnection](#communicationconnection)
  - [Properties](#properties)
  - [Methods](#methods)
- [CommunicationMessage](#communicationmessage)
  - [Properties](#properties)
  - [Initialization](#initialization)
  - [Message Types](#message-types)
- [CommunicationError](#communicationerror)
  - [Error Types](#error-types)
  - [Properties](#properties)
  - [Example](#example)
- [ConnectionStatus](#connectionstatus)
  - [Status Types](#status-types)
  - [Example](#example)
- [Complete Example](#complete-example)
<!-- TOC END -->


## Overview

The RealTimeCommunicationManager API provides the core functionality for real-time communication in iOS applications. This document covers all public interfaces, classes, and methods available in the RealTimeCommunicationManager module.

## Table of Contents

- [RealTimeCommunicationManager](#realtimemunicationmanager)
- [CommunicationConfiguration](#communicationconfiguration)
- [CommunicationConnection](#communicationconnection)
- [CommunicationMessage](#communicationmessage)
- [CommunicationError](#communicationerror)
- [ConnectionStatus](#connectionstatus)

## RealTimeCommunicationManager

The main real-time communication manager class that coordinates all communication services.

### Initialization

```swift
let communicationManager = RealTimeCommunicationManager()
```

### Configuration

```swift
func configure(_ configuration: CommunicationConfiguration)
```

Configures the communication manager with the specified configuration.

**Parameters:**
- `configuration`: The communication configuration object

**Example:**
```swift
let config = CommunicationConfiguration()
config.webSocketEnabled = true
config.pushNotificationEnabled = true
config.messageQueueEnabled = true
config.autoReconnect = true
config.timeout = 30.0
config.maxRetries = 3

communicationManager.configure(config)
```

### Connection Management

```swift
func establishWebSocketConnection(to url: URL, completion: @escaping (Result<CommunicationConnection, CommunicationError>) -> Void)
```

Establishes a WebSocket connection to the specified URL.

**Parameters:**
- `url`: The WebSocket server URL
- `completion`: Completion handler called with the connection result

**Example:**
```swift
guard let url = URL(string: "wss://api.company.com/ws") else { return }

communicationManager.establishWebSocketConnection(to: url) { result in
    switch result {
    case .success(let connection):
        print("✅ WebSocket connected: \(connection.id)")
    case .failure(let error):
        print("❌ WebSocket connection failed: \(error)")
    }
}
```

```swift
func disconnect(completion: @escaping (Result<Void, CommunicationError>) -> Void)
```

Disconnects the current connection.

**Parameters:**
- `completion`: Completion handler called with the disconnection result

**Example:**
```swift
communicationManager.disconnect { result in
    switch result {
    case .success:
        print("✅ Disconnected successfully")
    case .failure(let error):
        print("❌ Disconnection failed: \(error)")
    }
}
```

### Message Handling

```swift
func sendRealTimeMessage(_ message: CommunicationMessage, to recipients: [String], completion: @escaping (Result<Void, CommunicationError>) -> Void)
```

Sends a real-time message to specified recipients.

**Parameters:**
- `message`: The message to send
- `recipients`: Array of recipient identifiers
- `completion`: Completion handler called with the send result

**Example:**
```swift
let message = CommunicationMessage(
    title: "Hello",
    body: "This is a real-time message",
    data: "Hello World".data(using: .utf8)!,
    type: .text,
    senderId: "user123"
)

communicationManager.sendRealTimeMessage(message, to: ["recipient1", "recipient2"]) { result in
    switch result {
    case .success:
        print("✅ Message sent successfully")
    case .failure(let error):
        print("❌ Message failed: \(error)")
    }
}
```

```swift
func sendMessageToRoom(_ message: CommunicationMessage, roomId: String, completion: @escaping (Result<Void, CommunicationError>) -> Void)
```

Sends a message to a specific room.

**Parameters:**
- `message`: The message to send
- `roomId`: The room identifier
- `completion`: Completion handler called with the send result

**Example:**
```swift
communicationManager.sendMessageToRoom(message, roomId: "chat_room_123") { result in
    switch result {
    case .success:
        print("✅ Message sent to room")
    case .failure(let error):
        print("❌ Room message failed: \(error)")
    }
}
```

### Message Reception

```swift
func onMessageReceived(_ handler: @escaping (CommunicationMessage) -> Void)
```

Sets up a handler for incoming messages.

**Parameters:**
- `handler`: Closure called when a message is received

**Example:**
```swift
communicationManager.onMessageReceived { message in
    print("📨 Received message: \(message.title)")
    print("From: \(message.senderId)")
    print("Type: \(message.type)")
    
    if let data = message.data,
       let text = String(data: data, encoding: .utf8) {
        print("Content: \(text)")
    }
}
```

```swift
func onRoomMessageReceived(_ handler: @escaping (CommunicationMessage, String) -> Void)
```

Sets up a handler for room messages.

**Parameters:**
- `handler`: Closure called when a room message is received

**Example:**
```swift
communicationManager.onRoomMessageReceived { message, roomId in
    print("📨 Room message from \(roomId): \(message.title)")
}
```

### Connection Status

```swift
func onConnectionStatusChanged(_ handler: @escaping (ConnectionStatus) -> Void)
```

Sets up a handler for connection status changes.

**Parameters:**
- `handler`: Closure called when connection status changes

**Example:**
```swift
communicationManager.onConnectionStatusChanged { status in
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

### Room Management

```swift
func joinRoom(_ roomId: String, completion: @escaping (Result<Void, CommunicationError>) -> Void)
```

Joins a communication room.

**Parameters:**
- `roomId`: The room identifier
- `completion`: Completion handler called with the join result

**Example:**
```swift
communicationManager.joinRoom("chat_room_123") { result in
    switch result {
    case .success:
        print("✅ Joined room successfully")
    case .failure(let error):
        print("❌ Join room failed: \(error)")
    }
}
```

```swift
func leaveRoom(_ roomId: String, completion: @escaping (Result<Void, CommunicationError>) -> Void)
```

Leaves a communication room.

**Parameters:**
- `roomId`: The room identifier
- `completion`: Completion handler called with the leave result

**Example:**
```swift
communicationManager.leaveRoom("chat_room_123") { result in
    switch result {
    case .success:
        print("✅ Left room successfully")
    case .failure(let error):
        print("❌ Leave room failed: \(error)")
    }
}
```

### Push Notifications

```swift
func registerForPushNotifications(completion: @escaping (Result<String, CommunicationError>) -> Void)
```

Registers for push notifications.

**Parameters:**
- `completion`: Completion handler called with the registration result

**Example:**
```swift
communicationManager.registerForPushNotifications { result in
    switch result {
    case .success(let deviceToken):
        print("✅ Push notification registered: \(deviceToken)")
    case .failure(let error):
        print("❌ Push notification registration failed: \(error)")
    }
}
```

```swift
func sendPushNotification(_ notification: PushNotification, completion: @escaping (Result<Void, CommunicationError>) -> Void)
```

Sends a push notification.

**Parameters:**
- `notification`: The push notification to send
- `completion`: Completion handler called with the send result

**Example:**
```swift
let notification = PushNotification(
    id: UUID().uuidString,
    title: "New Message",
    body: "You have a new message",
    recipientId: "user456",
    type: .message
)

communicationManager.sendPushNotification(notification) { result in
    switch result {
    case .success:
        print("✅ Push notification sent")
    case .failure(let error):
        print("❌ Push notification failed: \(error)")
    }
}
```

### Message Queue

```swift
func enableMessageQueue(_ enabled: Bool)
```

Enables or disables the message queue.

**Parameters:**
- `enabled`: Whether to enable the message queue

**Example:**
```swift
communicationManager.enableMessageQueue(true)
```

```swift
func processMessageQueue(completion: @escaping (Result<Void, CommunicationError>) -> Void)
```

Processes the message queue.

**Parameters:**
- `completion`: Completion handler called with the processing result

**Example:**
```swift
communicationManager.processMessageQueue { result in
    switch result {
    case .success:
        print("✅ Message queue processed")
    case .failure(let error):
        print("❌ Message queue processing failed: \(error)")
    }
}
```

## CommunicationConfiguration

Configuration class for real-time communication settings.

### Properties

```swift
var webSocketEnabled: Bool
```

Whether to enable WebSocket functionality.

```swift
var pushNotificationEnabled: Bool
```

Whether to enable push notifications.

```swift
var messageQueueEnabled: Bool
```

Whether to enable message queuing.

```swift
var autoReconnect: Bool
```

Whether to enable automatic reconnection.

```swift
var timeout: TimeInterval
```

The connection timeout in seconds.

```swift
var maxRetries: Int
```

The maximum number of retry attempts.

```swift
var heartbeatInterval: TimeInterval
```

The heartbeat interval in seconds.

```swift
var enableEncryption: Bool
```

Whether to enable message encryption.

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
let config = CommunicationConfiguration()
config.webSocketEnabled = true
config.pushNotificationEnabled = true
config.messageQueueEnabled = true
config.autoReconnect = true
config.timeout = 30.0
config.maxRetries = 3
config.heartbeatInterval = 30.0
config.enableEncryption = true
config.enableCompression = true
config.maxMessageSize = 1024 * 1024 // 1MB
```

## CommunicationConnection

Represents a communication connection.

### Properties

```swift
var id: String
```

The unique connection identifier.

```swift
var url: URL
```

The connection URL.

```swift
var status: ConnectionStatus
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

```swift
var metadata: [String: Any]
```

Connection metadata.

### Methods

```swift
func send(_ message: CommunicationMessage, completion: @escaping (Result<Void, CommunicationError>) -> Void)
```

Sends a message through this connection.

**Parameters:**
- `message`: The message to send
- `completion`: Completion handler called with the send result

```swift
func close(completion: @escaping (Result<Void, CommunicationError>) -> Void)
```

Closes the connection.

**Parameters:**
- `completion`: Completion handler called with the close result

## CommunicationMessage

Represents a communication message.

### Properties

```swift
var id: String
```

The unique message identifier.

```swift
var title: String
```

The message title.

```swift
var body: String
```

The message body.

```swift
var data: Data?
```

The message data.

```swift
var type: MessageType
```

The message type.

```swift
var senderId: String
```

The sender identifier.

```swift
var recipientIds: [String]
```

The recipient identifiers.

```swift
var timestamp: Date
```

The message timestamp.

```swift
var metadata: [String: Any]
```

Message metadata.

### Initialization

```swift
init(title: String, body: String, data: Data?, type: MessageType, senderId: String)
```

Creates a new communication message.

**Parameters:**
- `title`: The message title
- `body`: The message body
- `data`: The message data
- `type`: The message type
- `senderId`: The sender identifier

**Example:**
```swift
let message = CommunicationMessage(
    title: "Hello",
    body: "This is a test message",
    data: "Hello World".data(using: .utf8),
    type: .text,
    senderId: "user123"
)
```

### Message Types

```swift
enum MessageType {
    case text
    case binary
    case image
    case video
    case audio
    case file
    case system
    case notification
}
```

## CommunicationError

Represents communication errors.

### Error Types

```swift
enum CommunicationError: Error {
    case connectionFailed(String)
    case authenticationFailed(String)
    case messageSendFailed(String)
    case messageReceiveFailed(String)
    case timeout(String)
    case networkError(String)
    case serverError(String)
    case invalidMessage(String)
    case encryptionError(String)
    case compressionError(String)
    case queueFull(String)
    case roomNotFound(String)
    case permissionDenied(String)
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
communicationManager.onError { error in
    switch error {
    case .connectionFailed(let reason):
        print("❌ Connection failed: \(reason)")
    case .authenticationFailed(let reason):
        print("❌ Authentication failed: \(reason)")
    case .messageSendFailed(let reason):
        print("❌ Message send failed: \(reason)")
    case .messageReceiveFailed(let reason):
        print("❌ Message receive failed: \(reason)")
    case .timeout(let operation):
        print("❌ Timeout: \(operation)")
    case .networkError(let message):
        print("❌ Network error: \(message)")
    case .serverError(let message):
        print("❌ Server error: \(message)")
    case .invalidMessage(let reason):
        print("❌ Invalid message: \(reason)")
    case .encryptionError(let reason):
        print("❌ Encryption error: \(reason)")
    case .compressionError(let reason):
        print("❌ Compression error: \(reason)")
    case .queueFull(let reason):
        print("❌ Queue full: \(reason)")
    case .roomNotFound(let roomId):
        print("❌ Room not found: \(roomId)")
    case .permissionDenied(let resource):
        print("❌ Permission denied: \(resource)")
    }
}
```

## ConnectionStatus

Represents connection status.

### Status Types

```swift
enum ConnectionStatus {
    case connecting
    case connected
    case disconnected
    case reconnecting
    case failed(CommunicationError)
}
```

### Example

```swift
communicationManager.onConnectionStatusChanged { status in
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

class CommunicationManager: ObservableObject {
    private let communicationManager = RealTimeCommunicationManager()
    
    @Published var isConnected = false
    @Published var messages: [CommunicationMessage] = []
    @Published var connectionStatus: ConnectionStatus = .disconnected
    
    init() {
        setupCommunication()
    }
    
    private func setupCommunication() {
        let config = CommunicationConfiguration()
        config.webSocketEnabled = true
        config.pushNotificationEnabled = true
        config.messageQueueEnabled = true
        config.autoReconnect = true
        config.timeout = 30.0
        config.maxRetries = 3
        config.heartbeatInterval = 30.0
        config.enableEncryption = true
        config.enableCompression = true
        config.maxMessageSize = 1024 * 1024 // 1MB
        
        communicationManager.configure(config)
        
        // Setup connection status monitoring
        communicationManager.onConnectionStatusChanged { [weak self] status in
            DispatchQueue.main.async {
                self?.connectionStatus = status
                self?.isConnected = (status == .connected)
            }
        }
        
        // Setup message reception
        communicationManager.onMessageReceived { [weak self] message in
            DispatchQueue.main.async {
                self?.messages.append(message)
            }
        }
        
        // Setup room message reception
        communicationManager.onRoomMessageReceived { [weak self] message, roomId in
            DispatchQueue.main.async {
                self?.messages.append(message)
            }
        }
    }
    
    func connect() {
        guard let url = URL(string: "wss://api.company.com/ws") else { return }
        
        communicationManager.establishWebSocketConnection(to: url) { result in
            switch result {
            case .success(let connection):
                print("✅ Connected: \(connection.id)")
            case .failure(let error):
                print("❌ Connection failed: \(error)")
            }
        }
    }
    
    func disconnect() {
        communicationManager.disconnect { result in
            switch result {
            case .success:
                print("✅ Disconnected")
            case .failure(let error):
                print("❌ Disconnection failed: \(error)")
            }
        }
    }
    
    func sendMessage(_ text: String, to recipients: [String]) {
        let message = CommunicationMessage(
            title: "Message",
            body: text,
            data: text.data(using: .utf8),
            type: .text,
            senderId: "current_user"
        )
        
        communicationManager.sendRealTimeMessage(message, to: recipients) { result in
            switch result {
            case .success:
                print("✅ Message sent")
            case .failure(let error):
                print("❌ Message failed: \(error)")
            }
        }
    }
    
    func sendMessageToRoom(_ text: String, roomId: String) {
        let message = CommunicationMessage(
            title: "Room Message",
            body: text,
            data: text.data(using: .utf8),
            type: .text,
            senderId: "current_user"
        )
        
        communicationManager.sendMessageToRoom(message, roomId: roomId) { result in
            switch result {
            case .success:
                print("✅ Room message sent")
            case .failure(let error):
                print("❌ Room message failed: \(error)")
            }
        }
    }
    
    func joinRoom(_ roomId: String) {
        communicationManager.joinRoom(roomId) { result in
            switch result {
            case .success:
                print("✅ Joined room: \(roomId)")
            case .failure(let error):
                print("❌ Join room failed: \(error)")
            }
        }
    }
    
    func leaveRoom(_ roomId: String) {
        communicationManager.leaveRoom(roomId) { result in
            switch result {
            case .success:
                print("✅ Left room: \(roomId)")
            case .failure(let error):
                print("❌ Leave room failed: \(error)")
            }
        }
    }
    
    func registerForPushNotifications() {
        communicationManager.registerForPushNotifications { result in
            switch result {
            case .success(let deviceToken):
                print("✅ Push notification registered: \(deviceToken)")
            case .failure(let error):
                print("❌ Push notification registration failed: \(error)")
            }
        }
    }
    
    func sendPushNotification(_ title: String, body: String, to recipientId: String) {
        let notification = PushNotification(
            id: UUID().uuidString,
            title: title,
            body: body,
            recipientId: recipientId,
            type: .message
        )
        
        communicationManager.sendPushNotification(notification) { result in
            switch result {
            case .success:
                print("✅ Push notification sent")
            case .failure(let error):
                print("❌ Push notification failed: \(error)")
            }
        }
    }
}

struct CommunicationView: View {
    @StateObject private var communicationManager = CommunicationManager()
    @State private var messageText = ""
    @State private var recipientIds = ""
    @State private var roomId = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Connection status
                HStack {
                    Circle()
                        .fill(communicationManager.isConnected ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                    Text(communicationManager.connectionStatus.rawValue.capitalized)
                }
                .padding()
                
                // Messages
                ScrollView {
                    LazyVStack {
                        ForEach(communicationManager.messages, id: \.id) { message in
                            VStack(alignment: .leading) {
                                Text(message.title)
                                    .font(.headline)
                                Text(message.body)
                                    .font(.body)
                                Text("From: \(message.senderId)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("Time: \(message.timestamp, style: .time)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                
                // Message input
                VStack {
                    TextField("Recipient IDs (comma separated)", text: $recipientIds)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Room ID", text: $roomId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Message", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        Button("Send to Users") {
                            let recipients = recipientIds.split(separator: ",").map(String.init)
                            communicationManager.sendMessage(messageText, to: recipients)
                            messageText = ""
                        }
                        .disabled(messageText.isEmpty || recipientIds.isEmpty)
                        
                        Button("Send to Room") {
                            communicationManager.sendMessageToRoom(messageText, roomId: roomId)
                            messageText = ""
                        }
                        .disabled(messageText.isEmpty || roomId.isEmpty)
                    }
                }
                .padding()
                
                // Actions
                VStack(spacing: 10) {
                    Button("Connect") {
                        communicationManager.connect()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(communicationManager.isConnected)
                    
                    Button("Disconnect") {
                        communicationManager.disconnect()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!communicationManager.isConnected)
                    
                    Button("Join Room") {
                        communicationManager.joinRoom(roomId)
                    }
                    .buttonStyle(.bordered)
                    .disabled(roomId.isEmpty)
                    
                    Button("Leave Room") {
                        communicationManager.leaveRoom(roomId)
                    }
                    .buttonStyle(.bordered)
                    .disabled(roomId.isEmpty)
                    
                    Button("Register Push Notifications") {
                        communicationManager.registerForPushNotifications()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle("Real-Time Communication")
        }
    }
}

extension ConnectionStatus: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: String) {
        switch rawValue {
        case "connecting": self = .connecting
        case "connected": self = .connected
        case "disconnected": self = .disconnected
        case "reconnecting": self = .reconnecting
        default: return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .connecting: return "connecting"
        case .connected: return "connected"
        case .disconnected: return "disconnected"
        case .reconnecting: return "reconnecting"
        case .failed: return "failed"
        }
    }
}
```

This comprehensive API documentation covers all aspects of the RealTimeCommunicationManager module in the iOS Real-Time Communication Framework. For more examples and advanced usage, refer to the RealTimeCommunicationManager Guide and other documentation.
