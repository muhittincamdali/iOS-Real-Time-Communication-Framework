# WebSocket Guide

<!-- TOC START -->
## Table of Contents
- [WebSocket Guide](#websocket-guide)
- [Overview](#overview)
- [Table of Contents](#table-of-contents)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Basic Setup](#basic-setup)
- [Basic Configuration](#basic-configuration)
  - [WebSocket Configuration Options](#websocket-configuration-options)
  - [Advanced Configuration](#advanced-configuration)
- [Connection Management](#connection-management)
  - [Establishing Connection](#establishing-connection)
  - [Connection Status Monitoring](#connection-status-monitoring)
  - [Manual Reconnection](#manual-reconnection)
- [Message Handling](#message-handling)
  - [Sending Messages](#sending-messages)
  - [Receiving Messages](#receiving-messages)
  - [Message Queuing](#message-queuing)
- [Error Handling](#error-handling)
  - [Connection Errors](#connection-errors)
  - [Message Errors](#message-errors)
- [Security](#security)
  - [SSL/TLS Configuration](#ssltls-configuration)
  - [Certificate Pinning](#certificate-pinning)
  - [Authentication](#authentication)
- [Performance Optimization](#performance-optimization)
  - [Connection Pooling](#connection-pooling)
  - [Message Compression](#message-compression)
  - [Memory Management](#memory-management)
- [Best Practices](#best-practices)
  - [1. Connection Management](#1-connection-management)
  - [2. Message Handling](#2-message-handling)
  - [3. Error Handling](#3-error-handling)
  - [4. Security](#4-security)
  - [5. Performance](#5-performance)
  - [6. Testing](#6-testing)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Debug Mode](#debug-mode)
- [Examples](#examples)
  - [Complete WebSocket Implementation](#complete-websocket-implementation)
<!-- TOC END -->


## Overview

The WebSocket module provides comprehensive real-time communication capabilities for iOS applications. This guide covers everything you need to know about implementing WebSocket connections in your iOS app.

## Table of Contents

- [Getting Started](#getting-started)
- [Basic Configuration](#basic-configuration)
- [Connection Management](#connection-management)
- [Message Handling](#message-handling)
- [Error Handling](#error-handling)
- [Security](#security)
- [Performance Optimization](#performance-optimization)
- [Best Practices](#best-practices)

## Getting Started

### Prerequisites

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

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

// Initialize WebSocket client
let webSocketClient = WebSocketClient()

// Configure WebSocket
let config = WebSocketConfiguration()
config.url = "wss://your-server.com/ws"
config.enableReconnection = true
config.heartbeatInterval = 30
config.maxReconnectionAttempts = 5

// Setup client
webSocketClient.configure(config)
```

## Basic Configuration

### WebSocket Configuration Options

```swift
let config = WebSocketConfiguration()

// Connection settings
config.url = "wss://api.company.com/ws"
config.timeout = 30.0
config.enableReconnection = true
config.maxReconnectionAttempts = 5
config.reconnectionDelay = 1000

// Heartbeat settings
config.enableHeartbeat = true
config.heartbeatInterval = 30
config.heartbeatTimeout = 10

// Security settings
config.enableSSL = true
config.enableCertificatePinning = true
config.allowedHosts = ["api.company.com"]

// Performance settings
config.enableCompression = true
config.maxMessageSize = 1024 * 1024 // 1MB
config.enableMessageQueuing = true
```

### Advanced Configuration

```swift
// Custom headers
config.customHeaders = [
    "Authorization": "Bearer your-token",
    "User-Agent": "iOS-RealTime-Communication/2.1.0"
]

// Protocol settings
config.protocols = ["websocket", "wss"]
config.enableBinaryMessages = true
config.enableTextMessages = true

// Logging settings
config.enableLogging = true
config.logLevel = .debug
```

## Connection Management

### Establishing Connection

```swift
// Connect to WebSocket
webSocketClient.connect { result in
    switch result {
    case .success(let connection):
        print("✅ WebSocket connected: \(connection.id)")
    case .failure(let error):
        print("❌ WebSocket connection failed: \(error)")
    }
}
```

### Connection Status Monitoring

```swift
// Monitor connection status
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
    case .failed:
        print("❌ Connection failed")
    }
}
```

### Manual Reconnection

```swift
// Manual reconnection
webSocketClient.reconnect { result in
    switch result {
    case .success:
        print("✅ Reconnected successfully")
    case .failure(let error):
        print("❌ Reconnection failed: \(error)")
    }
}
```

## Message Handling

### Sending Messages

```swift
// Send text message
let textMessage = WebSocketMessage(
    type: .text,
    data: "Hello, WebSocket!"
)

webSocketClient.send(textMessage) { result in
    switch result {
    case .success:
        print("✅ Text message sent")
    case .failure(let error):
        print("❌ Text message failed: \(error)")
    }
}

// Send binary message
let binaryData = "Hello, Binary!".data(using: .utf8)!
let binaryMessage = WebSocketMessage(
    type: .binary,
    data: binaryData
)

webSocketClient.send(binaryMessage) { result in
    switch result {
    case .success:
        print("✅ Binary message sent")
    case .failure(let error):
        print("❌ Binary message failed: \(error)")
    }
}
```

### Receiving Messages

```swift
// Listen for incoming messages
webSocketClient.onMessage { message in
    switch message.type {
    case .text:
        if let text = String(data: message.data, encoding: .utf8) {
            print("📨 Text message: \(text)")
        }
    case .binary:
        print("📨 Binary message: \(message.data.count) bytes")
    case .ping:
        print("🏓 Ping received")
    case .pong:
        print("🏓 Pong received")
    case .close:
        print("🔒 Close frame received")
    }
}
```

### Message Queuing

```swift
// Enable message queuing
let queueConfig = MessageQueueConfiguration()
queueConfig.enableQueuing = true
queueConfig.maxQueueSize = 100
queueConfig.retryAttempts = 3
queueConfig.retryDelay = 1000

webSocketClient.configureMessageQueue(queueConfig)
```

## Error Handling

### Connection Errors

```swift
// Handle connection errors
webSocketClient.onError { error in
    switch error {
    case .connectionFailed(let reason):
        print("❌ Connection failed: \(reason)")
    case .authenticationFailed(let reason):
        print("❌ Authentication failed: \(reason)")
    case .timeout:
        print("❌ Connection timeout")
    case .networkError(let error):
        print("❌ Network error: \(error)")
    case .sslError(let error):
        print("❌ SSL error: \(error)")
    }
}
```

### Message Errors

```swift
// Handle message errors
webSocketClient.onMessageError { error in
    switch error {
    case .messageTooLarge(let size):
        print("❌ Message too large: \(size) bytes")
    case .invalidMessageFormat:
        print("❌ Invalid message format")
    case .encodingError(let error):
        print("❌ Encoding error: \(error)")
    }
}
```

## Security

### SSL/TLS Configuration

```swift
// SSL/TLS settings
let sslConfig = SSLConfiguration()
sslConfig.enableSSL = true
sslConfig.allowSelfSignedCertificates = false
sslConfig.verifyHostname = true
sslConfig.cipherSuites = [.tlsAES256GCM, .tlsCHACHA20POLY1305]

webSocketClient.configureSSL(sslConfig)
```

### Certificate Pinning

```swift
// Certificate pinning
let pinningConfig = CertificatePinningConfiguration()
pinningConfig.enablePinning = true
pinningConfig.pinnedCertificates = [
    "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
    "sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
]

webSocketClient.configureCertificatePinning(pinningConfig)
```

### Authentication

```swift
// Token-based authentication
let authConfig = AuthenticationConfiguration()
authConfig.token = "your-jwt-token"
authConfig.tokenRefreshHandler = { completion in
    // Refresh token logic
    let newToken = "refreshed-token"
    completion(.success(newToken))
}

webSocketClient.configureAuthentication(authConfig)
```

## Performance Optimization

### Connection Pooling

```swift
// Enable connection pooling
let poolConfig = ConnectionPoolConfiguration()
poolConfig.enablePooling = true
poolConfig.maxConnections = 5
poolConfig.connectionTimeout = 30
poolConfig.idleTimeout = 300

webSocketClient.configureConnectionPool(poolConfig)
```

### Message Compression

```swift
// Enable message compression
let compressionConfig = CompressionConfiguration()
compressionConfig.enableCompression = true
compressionConfig.compressionLevel = 6
compressionConfig.minSizeForCompression = 1024

webSocketClient.configureCompression(compressionConfig)
```

### Memory Management

```swift
// Memory optimization
let memoryConfig = MemoryConfiguration()
memoryConfig.maxMessageBufferSize = 1024 * 1024 // 1MB
memoryConfig.enableMessageCleanup = true
memoryConfig.cleanupInterval = 60 // seconds

webSocketClient.configureMemory(memoryConfig)
```

## Best Practices

### 1. Connection Management

- Always implement proper connection lifecycle management
- Use automatic reconnection for production apps
- Monitor connection health with heartbeats
- Handle network transitions gracefully

### 2. Message Handling

- Implement proper message validation
- Use appropriate message types (text vs binary)
- Handle large messages efficiently
- Implement message queuing for offline scenarios

### 3. Error Handling

- Implement comprehensive error handling
- Provide user-friendly error messages
- Log errors for debugging
- Implement retry mechanisms

### 4. Security

- Always use WSS (WebSocket Secure) in production
- Implement certificate pinning
- Validate all incoming messages
- Use proper authentication

### 5. Performance

- Monitor connection performance
- Implement message compression for large payloads
- Use connection pooling for multiple connections
- Optimize memory usage

### 6. Testing

- Test with various network conditions
- Test reconnection scenarios
- Test with different message sizes
- Test security configurations

## Troubleshooting

### Common Issues

1. **Connection Fails**
   - Check server URL and port
   - Verify SSL certificate
   - Check network connectivity

2. **Messages Not Received**
   - Verify message format
   - Check message size limits
   - Ensure proper event handling

3. **Reconnection Issues**
   - Check reconnection configuration
   - Verify server availability
   - Monitor network status

4. **Performance Issues**
   - Enable message compression
   - Optimize message size
   - Use connection pooling

### Debug Mode

```swift
// Enable debug logging
let debugConfig = DebugConfiguration()
debugConfig.enableLogging = true
debugConfig.logLevel = .debug
debugConfig.enableNetworkLogging = true

webSocketClient.configureDebug(debugConfig)
```

## Examples

### Complete WebSocket Implementation

```swift
import RealTimeCommunication
import SwiftUI

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
    }
    
    func connect() {
        webSocketClient.connect { result in
            switch result {
            case .success:
                print("✅ Connected to WebSocket")
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
        webSocketClient.disconnect()
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
                            .background(Color.gray.opacity(0.2))
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

This comprehensive guide covers all aspects of WebSocket implementation in the iOS Real-Time Communication Framework. For more advanced features and examples, refer to the API documentation and other guides.
