# 📚 API Reference

## RealTimeManager

The main entry point for the iOS Real-Time Communication Framework.

### Initialization

```swift
let config = RealTimeConfig(
    serverURL: "wss://your-server.com",
    apiKey: "your-api-key",
    enablePushNotifications: true,
    enableAnalytics: true
)

let realTimeManager = RealTimeManager(configuration: config)
```

### Connection Management

```swift
// Connect to server
let result = try await realTimeManager.connect()

// Disconnect from server
let disconnectionResult = await realTimeManager.disconnect()
```

### Message Handling

```swift
// Send message
realTimeManager.send(message: message, priority: .high) { result in
    switch result {
    case .success:
        print("Message sent successfully")
    case .failure(let error):
        print("Failed to send message: \(error)")
    }
}

// Receive messages
realTimeManager.onMessage { message in
    print("Received: \(message)")
}
```

### Push Notifications

```swift
// Handle push notifications
realTimeManager.onPushNotification { notification in
    print("Received push: \(notification)")
}
```

### Analytics

```swift
// Get health metrics
let healthMetrics = realTimeManager.getHealthMetrics()

// Get analytics data
let analytics = realTimeManager.getAnalytics()
```

## WebSocketManager

Handles WebSocket connections and message handling.

### Connection

```swift
let webSocketManager = WebSocketManager(configuration: config)

// Connect
let result = try await webSocketManager.connect()

// Disconnect
try await webSocketManager.disconnect()
```

### Message Sending

```swift
// Send message
try webSocketManager.send(message: message)

// Check connection status
let isConnected = webSocketManager.isConnected
```

## PushNotificationManager

Manages push notification registration and delivery.

### Registration

```swift
let pushManager = PushNotificationManager(configuration: config)

// Register for push notifications
try await pushManager.register()

// Unregister
try await pushManager.unregister()
```

### Device Token

```swift
// Set device token
pushManager.setDeviceToken(deviceToken)

// Get device token
let token = pushManager.getDeviceToken()
```

## MessageQueueManager

Handles message queuing with persistence and priority support.

### Queue Management

```swift
let queueManager = MessageQueueManager(configuration: config)

// Start processing
queueManager.startProcessing()

// Stop processing
queueManager.stopProcessing()
```

### Message Operations

```swift
// Add message to queue
try queueManager.addMessage(message, priority: .high)

// Remove message
queueManager.removeMessage(withID: messageID)

// Get queue size
let size = queueManager.getQueueSize()
```

## AnalyticsManager

Tracks analytics and performance metrics.

### Event Tracking

```swift
let analyticsManager = AnalyticsManager(configuration: config)

// Track event
analyticsManager.trackEvent(.messageSent, properties: ["size": 1024])

// Track metric
analyticsManager.trackMetric(.connectionLatency, value: 150.0, unit: "ms")
```

### Data Retrieval

```swift
// Get analytics data
let analytics = analyticsManager.getAnalytics()

// Get performance metrics
let metrics = analyticsManager.getPerformanceMetrics()
```

## ConnectionManager

Manages connection lifecycle and health monitoring.

### Health Monitoring

```swift
let connectionManager = ConnectionManager(configuration: config)

// Get health metrics
let healthMetrics = connectionManager.getHealthMetrics()

// Perform health check
connectionManager.performHealthCheck()
```

### Connection Pool

```swift
// Add connection
connectionManager.addConnection(connection)

// Remove connection
connectionManager.removeConnection(connection)

// Get best connection
let bestConnection = connectionManager.getBestConnection()
```

## Error Types

### ConnectionError

```swift
enum ConnectionError: Error {
    case networkUnavailable
    case authenticationFailed
    case connectionFailed(Error)
    case disconnectionFailed(Error)
    case timeout
    case serverUnreachable
}
```

### MessageError

```swift
enum MessageError: Error {
    case sendFailed(Error)
    case receiveFailed(Error)
    case serializationFailed(Error)
    case deserializationFailed(Error)
    case connectionNotAvailable
    case queueFull
    case invalidMessage
}
```

### PushNotificationError

```swift
enum PushNotificationError: Error {
    case authorizationFailed(Error)
    case authorizationDenied
    case registrationFailed(Error)
    case unregistrationFailed(Error)
    case schedulingFailed(Error)
    case invalidNotificationFormat
    case deviceTokenNotAvailable
}
```

## Configuration

### RealTimeConfig

```swift
let config = RealTimeConfig(
    serverURL: "wss://your-server.com",
    apiKey: "your-api-key",
    port: 443,
    path: "/",
    connectionTimeout: 30,
    heartbeatInterval: 30,
    maxReconnectionAttempts: 5,
    reconnectionDelay: 1,
    reconnectionBackoffMultiplier: 2.0,
    enablePushNotifications: true,
    enableAnalytics: true,
    enableMessageQueuing: true,
    enableConnectionPooling: true,
    enableEncryption: true,
    certificatePinning: certificatePinningConfig,
    tokenAuthentication: tokenAuthConfig,
    maxMessageSize: 1024 * 1024,
    messageBatchSize: 100,
    connectionPoolSize: 5,
    analyticsFlushInterval: 60,
    logLevel: .info,
    enableDebugLogging: false
)
```

## Best Practices

### Error Handling

```swift
do {
    try await realTimeManager.connect()
} catch ConnectionError.networkUnavailable {
    // Handle network unavailability
} catch ConnectionError.authenticationFailed {
    // Handle authentication failure
} catch {
    // Handle other errors
}
```

### Performance Optimization

```swift
// Use appropriate message priorities
realTimeManager.send(message: urgentMessage, priority: .high)
realTimeManager.send(message: normalMessage, priority: .normal)
realTimeManager.send(message: backgroundMessage, priority: .low)

// Monitor health metrics
let health = realTimeManager.getHealthMetrics()
if health.latency > 1000 {
    // Handle high latency
}
```

### Security

```swift
// Enable encryption
let secureConfig = RealTimeConfig(
    serverURL: "wss://secure-server.com",
    apiKey: "secure-api-key",
    enableEncryption: true,
    certificatePinning: CertificatePinningConfig(
        certificateHashes: ["your-cert-hash"],
        enabled: true
    )
)
```

## Migration Guide

### From Version 0.x to 1.0

1. Update initialization:
   ```swift
   // Old
   let manager = RealTimeManager()
   
   // New
   let config = RealTimeConfig(serverURL: "...", apiKey: "...")
   let manager = RealTimeManager(configuration: config)
   ```

2. Update connection handling:
   ```swift
   // Old
   manager.connect()
   
   // New
   let result = try await manager.connect()
   ```

3. Update message sending:
   ```swift
   // Old
   manager.send(message)
   
   // New
   manager.send(message: message, priority: .normal) { result in
       // Handle result
   }
   ``` 