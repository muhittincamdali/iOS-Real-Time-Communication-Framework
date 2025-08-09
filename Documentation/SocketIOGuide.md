# Socket.IO Guide

<!-- TOC START -->
## Table of Contents
- [Socket.IO Guide](#socketio-guide)
- [Overview](#overview)
- [Table of Contents](#table-of-contents)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Basic Setup](#basic-setup)
- [Basic Configuration](#basic-configuration)
  - [Socket.IO Configuration Options](#socketio-configuration-options)
  - [Advanced Configuration](#advanced-configuration)
- [Connection Management](#connection-management)
  - [Establishing Connection](#establishing-connection)
  - [Connection Status Monitoring](#connection-status-monitoring)
  - [Manual Reconnection](#manual-reconnection)
  - [Disconnection](#disconnection)
- [Event Handling](#event-handling)
  - [Emitting Events](#emitting-events)
  - [Listening for Events](#listening-for-events)
  - [Event Handler Management](#event-handler-management)
- [Room Management](#room-management)
  - [Joining Rooms](#joining-rooms)
  - [Leaving Rooms](#leaving-rooms)
  - [Room Events](#room-events)
- [Authentication](#authentication)
  - [Token-based Authentication](#token-based-authentication)
  - [Custom Authentication](#custom-authentication)
- [Error Handling](#error-handling)
  - [Connection Errors](#connection-errors)
  - [Event Errors](#event-errors)
- [Performance Optimization](#performance-optimization)
  - [Message Compression](#message-compression)
  - [Connection Pooling](#connection-pooling)
  - [Memory Management](#memory-management)
- [Best Practices](#best-practices)
  - [1. Connection Management](#1-connection-management)
  - [2. Event Handling](#2-event-handling)
  - [3. Room Management](#3-room-management)
  - [4. Error Handling](#4-error-handling)
  - [5. Security](#5-security)
  - [6. Performance](#6-performance)
  - [7. Testing](#7-testing)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Debug Mode](#debug-mode)
- [Examples](#examples)
  - [Complete Socket.IO Implementation](#complete-socketio-implementation)
<!-- TOC END -->


## Overview

The Socket.IO module provides a complete Socket.IO client implementation for iOS applications. This guide covers everything you need to know about implementing Socket.IO connections and real-time communication.

## Table of Contents

- [Getting Started](#getting-started)
- [Basic Configuration](#basic-configuration)
- [Connection Management](#connection-management)
- [Event Handling](#event-handling)
- [Room Management](#room-management)
- [Authentication](#authentication)
- [Error Handling](#error-handling)
- [Performance Optimization](#performance-optimization)
- [Best Practices](#best-practices)

## Getting Started

### Prerequisites

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+
- Socket.IO server

### Installation

Add the framework to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Real-Time-Communication-Framework.git", from: "2.1.0")
]
```

### Basic Setup

```swift
import RealTimeCommunication

// Initialize Socket.IO client
let socketIOClient = SocketIOClient()

// Configure Socket.IO
let config = SocketIOConfiguration()
config.serverURL = "https://your-server.com"
config.enableReconnection = true
config.reconnectionAttempts = 5
config.reconnectionDelay = 1000

// Setup client
socketIOClient.configure(config)
```

## Basic Configuration

### Socket.IO Configuration Options

```swift
let config = SocketIOConfiguration()

// Server settings
config.serverURL = "https://api.company.com"
config.path = "/socket.io/"
config.port = 443

// Connection settings
config.enableReconnection = true
config.reconnectionAttempts = 5
config.reconnectionDelay = 1000
config.reconnectionDelayMax = 5000
config.timeout = 20000

// Transport settings
config.transport = .websocket
config.enableForceNew = true
config.enableMultiplex = false

// Security settings
config.enableSSL = true
config.enableCertificatePinning = true
config.allowedHosts = ["api.company.com"]

// Performance settings
config.enableCompression = true
config.enableBinaryMessages = true
config.maxPayload = 1000000 // 1MB
```

### Advanced Configuration

```swift
// Custom headers
config.customHeaders = [
    "Authorization": "Bearer your-token",
    "User-Agent": "iOS-SocketIO-Client/2.1.0"
]

// Query parameters
config.queryParameters = [
    "client": "ios",
    "version": "2.1.0"
]

// Namespace configuration
config.namespace = "/chat"

// Logging settings
config.enableLogging = true
config.logLevel = .debug
```

## Connection Management

### Establishing Connection

```swift
// Connect to Socket.IO server
socketIOClient.connect { result in
    switch result {
    case .success(let connection):
        print("✅ Socket.IO connected: \(connection.id)")
    case .failure(let error):
        print("❌ Socket.IO connection failed: \(error)")
    }
}
```

### Connection Status Monitoring

```swift
// Monitor connection status
socketIOClient.onConnectionStatusChange { status in
    switch status {
    case .connecting:
        print("🔄 Connecting to Socket.IO...")
    case .connected:
        print("✅ Socket.IO connected")
    case .disconnected:
        print("❌ Socket.IO disconnected")
    case .reconnecting:
        print("🔄 Socket.IO reconnecting...")
    case .failed:
        print("❌ Socket.IO connection failed")
    }
}
```

### Manual Reconnection

```swift
// Manual reconnection
socketIOClient.reconnect { result in
    switch result {
    case .success:
        print("✅ Reconnected successfully")
    case .failure(let error):
        print("❌ Reconnection failed: \(error)")
    }
}
```

### Disconnection

```swift
// Graceful disconnection
socketIOClient.disconnect { result in
    switch result {
    case .success:
        print("✅ Disconnected gracefully")
    case .failure(let error):
        print("❌ Disconnection failed: \(error)")
    }
}
```

## Event Handling

### Emitting Events

```swift
// Emit simple event
socketIOClient.emit("message", data: ["text": "Hello, Socket.IO!"]) { result in
    switch result {
    case .success:
        print("✅ Event emitted successfully")
    case .failure(let error):
        print("❌ Event emission failed: \(error)")
    }
}

// Emit with acknowledgment
socketIOClient.emitWithAck("message", data: ["text": "Hello!"]) { result in
    switch result {
    case .success(let response):
        print("✅ Event acknowledged: \(response)")
    case .failure(let error):
        print("❌ Event acknowledgment failed: \(error)")
    }
}

// Emit binary data
let imageData = UIImage(named: "avatar")?.jpegData(compressionQuality: 0.8)
socketIOClient.emit("upload_image", data: ["image": imageData!]) { result in
    switch result {
    case .success:
        print("✅ Image uploaded")
    case .failure(let error):
        print("❌ Image upload failed: \(error)")
    }
}
```

### Listening for Events

```swift
// Listen for simple events
socketIOClient.on("message") { data in
    print("📨 Received message: \(data)")
}

// Listen for user events
socketIOClient.on("user_joined") { data in
    if let userData = data as? [String: Any],
       let username = userData["username"] as? String {
        print("👤 User joined: \(username)")
    }
}

// Listen for typing events
socketIOClient.on("typing_started") { data in
    if let userData = data as? [String: Any],
       let username = userData["username"] as? String {
        print("⌨️ \(username) started typing")
    }
}

socketIOClient.on("typing_stopped") { data in
    if let userData = data as? [String: Any],
       let username = userData["username"] as? String {
        print("⏹️ \(username) stopped typing")
    }
}

// Listen for system events
socketIOClient.on("connect") { _ in
    print("✅ Connected to Socket.IO server")
}

socketIOClient.on("disconnect") { _ in
    print("❌ Disconnected from Socket.IO server")
}

socketIOClient.on("error") { data in
    print("❌ Socket.IO error: \(data)")
}
```

### Event Handler Management

```swift
// Create event handler
let eventHandler = SocketIOEventHandler()

// Register event handlers
eventHandler.on("message") { data in
    print("📨 Message: \(data)")
}

eventHandler.on("notification") { data in
    print("🔔 Notification: \(data)")
}

// Set event handler
socketIOClient.setEventHandler(eventHandler)

// Remove specific event listener
socketIOClient.off("message")

// Remove all event listeners
socketIOClient.offAll()
```

## Room Management

### Joining Rooms

```swift
// Join a room
socketIOClient.joinRoom("chat_room_123") { result in
    switch result {
    case .success:
        print("✅ Joined chat room")
    case .failure(let error):
        print("❌ Failed to join room: \(error)")
    }
}

// Join multiple rooms
socketIOClient.joinRooms(["room1", "room2", "room3"]) { result in
    switch result {
    case .success:
        print("✅ Joined multiple rooms")
    case .failure(let error):
        print("❌ Failed to join rooms: \(error)")
    }
}
```

### Leaving Rooms

```swift
// Leave a room
socketIOClient.leaveRoom("chat_room_123") { result in
    switch result {
    case .success:
        print("✅ Left chat room")
    case .failure(let error):
        print("❌ Failed to leave room: \(error)")
    }
}

// Leave all rooms
socketIOClient.leaveAllRooms { result in
    switch result {
    case .success:
        print("✅ Left all rooms")
    case .failure(let error):
        print("❌ Failed to leave rooms: \(error)")
    }
}
```

### Room Events

```swift
// Listen for room events
socketIOClient.on("user_joined_room") { data in
    if let roomData = data as? [String: Any],
       let roomId = roomData["room"] as? String,
       let username = roomData["username"] as? String {
        print("👤 \(username) joined room: \(roomId)")
    }
}

socketIOClient.on("user_left_room") { data in
    if let roomData = data as? [String: Any],
       let roomId = roomData["room"] as? String,
       let username = roomData["username"] as? String {
        print("👋 \(username) left room: \(roomId)")
    }
}
```

## Authentication

### Token-based Authentication

```swift
// Configure authentication
let authConfig = SocketIOAuthenticationConfiguration()
authConfig.token = "your-jwt-token"
authConfig.tokenRefreshHandler = { completion in
    // Refresh token logic
    let newToken = "refreshed-token"
    completion(.success(newToken))
}

socketIOClient.configureAuthentication(authConfig)
```

### Custom Authentication

```swift
// Custom authentication
socketIOClient.authenticate(credentials: [
    "username": "user123",
    "password": "password123"
]) { result in
    switch result {
    case .success(let user):
        print("✅ Authenticated: \(user.username)")
    case .failure(let error):
        print("❌ Authentication failed: \(error)")
    }
}
```

## Error Handling

### Connection Errors

```swift
// Handle connection errors
socketIOClient.onError { error in
    switch error {
    case .connectionFailed(let reason):
        print("❌ Connection failed: \(reason)")
    case .authenticationFailed(let reason):
        print("❌ Authentication failed: \(reason)")
    case .timeout:
        print("❌ Connection timeout")
    case .serverError(let code, let message):
        print("❌ Server error \(code): \(message)")
    case .transportError(let error):
        print("❌ Transport error: \(error)")
    }
}
```

### Event Errors

```swift
// Handle event errors
socketIOClient.onEventError { error in
    switch error {
    case .eventNotFound(let eventName):
        print("❌ Event not found: \(eventName)")
    case .invalidEventData(let eventName, let data):
        print("❌ Invalid data for event \(eventName): \(data)")
    case .eventTimeout(let eventName):
        print("❌ Event timeout: \(eventName)")
    }
}
```

## Performance Optimization

### Message Compression

```swift
// Enable message compression
let compressionConfig = SocketIOCompressionConfiguration()
compressionConfig.enableCompression = true
compressionConfig.compressionLevel = 6
compressionConfig.minSizeForCompression = 1024

socketIOClient.configureCompression(compressionConfig)
```

### Connection Pooling

```swift
// Enable connection pooling
let poolConfig = SocketIOConnectionPoolConfiguration()
poolConfig.enablePooling = true
poolConfig.maxConnections = 3
poolConfig.connectionTimeout = 30
poolConfig.idleTimeout = 300

socketIOClient.configureConnectionPool(poolConfig)
```

### Memory Management

```swift
// Memory optimization
let memoryConfig = SocketIOMemoryConfiguration()
memoryConfig.maxEventBufferSize = 1024 * 1024 // 1MB
memoryConfig.enableEventCleanup = true
memoryConfig.cleanupInterval = 60 // seconds

socketIOClient.configureMemory(memoryConfig)
```

## Best Practices

### 1. Connection Management

- Always implement proper connection lifecycle management
- Use automatic reconnection for production apps
- Monitor connection health
- Handle network transitions gracefully

### 2. Event Handling

- Use descriptive event names
- Implement proper event validation
- Handle all possible event types
- Use acknowledgments for critical events

### 3. Room Management

- Join rooms only when needed
- Leave rooms when no longer needed
- Monitor room membership
- Handle room-specific events properly

### 4. Error Handling

- Implement comprehensive error handling
- Provide user-friendly error messages
- Log errors for debugging
- Implement retry mechanisms

### 5. Security

- Always use SSL/TLS in production
- Implement proper authentication
- Validate all incoming data
- Use secure token management

### 6. Performance

- Monitor connection performance
- Use message compression for large payloads
- Implement proper memory management
- Optimize event handling

### 7. Testing

- Test with various network conditions
- Test reconnection scenarios
- Test with different event types
- Test security configurations

## Troubleshooting

### Common Issues

1. **Connection Fails**
   - Check server URL and port
   - Verify SSL certificate
   - Check network connectivity
   - Verify authentication

2. **Events Not Received**
   - Verify event names
   - Check event registration
   - Ensure proper namespace
   - Verify server implementation

3. **Reconnection Issues**
   - Check reconnection configuration
   - Verify server availability
   - Monitor network status
   - Check authentication token

4. **Performance Issues**
   - Enable message compression
   - Optimize event payload size
   - Use connection pooling
   - Monitor memory usage

### Debug Mode

```swift
// Enable debug logging
let debugConfig = SocketIODebugConfiguration()
debugConfig.enableLogging = true
debugConfig.logLevel = .debug
debugConfig.enableNetworkLogging = true
debugConfig.enableEventLogging = true

socketIOClient.configureDebug(debugConfig)
```

## Examples

### Complete Socket.IO Implementation

```swift
import RealTimeCommunication
import SwiftUI

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
    }
    
    func connect() {
        socketIOClient.connect { result in
            switch result {
            case .success:
                print("✅ Connected to Socket.IO")
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
                print("❌ Failed to join room: \(error)")
            }
        }
    }
    
    func sendMessage(_ text: String, to roomId: String) {
        let messageData = [
            "text": text,
            "room": roomId,
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
        socketIOClient.emit("typing_started", data: ["room": roomId])
    }
    
    func stopTyping(in roomId: String) {
        socketIOClient.emit("typing_stopped", data: ["room": roomId])
    }
    
    func disconnect() {
        socketIOClient.disconnect()
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

This comprehensive guide covers all aspects of Socket.IO implementation in the iOS Real-Time Communication Framework. For more advanced features and examples, refer to the API documentation and other guides.
