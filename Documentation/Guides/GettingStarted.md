# 🚀 Getting Started

## Prerequisites

Before you begin, make sure you have:

- **Xcode**: 15.0 or later
- **iOS**: 15.0 or later
- **Swift**: 5.9 or later
- **CocoaPods** (optional): For CocoaPods installation

## Installation

### Swift Package Manager (Recommended)

1. **Add the package to your project**:
   - In Xcode, go to File → Add Package Dependencies
   - Enter the repository URL: `https://github.com/muhittincamdali/iOS-Real-Time-Communication-Framework.git`
   - Select version: `1.0.0`

2. **Or add to your Package.swift**:
   ```swift
   dependencies: [
       .package(url: "https://github.com/muhittincamdali/iOS-Real-Time-Communication-Framework.git", from: "1.0.0")
   ]
   ```

### CocoaPods

1. **Add to your Podfile**:
   ```ruby
   pod 'RealTimeCommunication', '~> 1.0.0'
   ```

2. **Install dependencies**:
   ```bash
   pod install
   ```

## Basic Setup

### 1. Import the Framework

```swift
import RealTimeCommunication
```

### 2. Create Configuration

```swift
let config = RealTimeConfig(
    serverURL: "wss://your-server.com",
    apiKey: "your-api-key",
    enablePushNotifications: true,
    enableAnalytics: true,
    enableMessageQueuing: true,
    enableConnectionPooling: true
)
```

### 3. Initialize the Manager

```swift
let realTimeManager = RealTimeManager(configuration: config)
```

## Quick Example

### Complete Setup

```swift
import UIKit
import RealTimeCommunication

class ChatViewController: UIViewController {
    
    private var realTimeManager: RealTimeManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRealTimeCommunication()
    }
    
    private func setupRealTimeCommunication() {
        // Create configuration
        let config = RealTimeConfig(
            serverURL: "wss://your-chat-server.com",
            apiKey: "your-api-key",
            enablePushNotifications: true,
            enableAnalytics: true
        )
        
        // Initialize manager
        realTimeManager = RealTimeManager(configuration: config)
        
        // Set up message handler
        realTimeManager.onMessage { [weak self] message in
            self?.handleReceivedMessage(message)
        }
        
        // Set up push notification handler
        realTimeManager.onPushNotification { [weak self] notification in
            self?.handlePushNotification(notification)
        }
        
        // Connect to server
        connectToServer()
    }
    
    private func connectToServer() {
        Task {
            do {
                let result = try await realTimeManager.connect()
                print("Connected successfully: \(result.sessionID)")
            } catch {
                print("Connection failed: \(error)")
            }
        }
    }
    
    private func sendMessage(_ text: String) {
        let message = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: text.data(using: .utf8)!,
            timestamp: Date(),
            sender: "user123",
            recipient: "room456"
        )
        
        realTimeManager.send(message: message, priority: .normal) { result in
            switch result {
            case .success:
                print("Message sent successfully")
            case .failure(let error):
                print("Failed to send message: \(error)")
            }
        }
    }
    
    private func handleReceivedMessage(_ message: RealTimeMessage) {
        DispatchQueue.main.async {
            // Update UI with received message
            print("Received message: \(message)")
        }
    }
    
    private func handlePushNotification(_ notification: PushNotification) {
        DispatchQueue.main.async {
            // Handle push notification
            print("Received push notification: \(notification.title)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Disconnect when leaving
        Task {
            await realTimeManager.disconnect()
        }
    }
}
```

## Advanced Configuration

### Custom Configuration

```swift
let advancedConfig = RealTimeConfig(
    serverURL: "wss://your-server.com",
    apiKey: "your-api-key",
    port: 443,
    path: "/websocket",
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
    certificatePinning: CertificatePinningConfig(
        certificateHashes: ["your-cert-hash"],
        enabled: true
    ),
    tokenAuthentication: TokenAuthenticationConfig(
        token: "your-auth-token",
        refreshURL: "https://your-server.com/refresh",
        expirationTime: Date().addingTimeInterval(3600),
        enableAutoRefresh: true
    ),
    maxMessageSize: 1024 * 1024,
    messageBatchSize: 100,
    connectionPoolSize: 5,
    analyticsFlushInterval: 60,
    logLevel: .info,
    enableDebugLogging: true
)
```

### Error Handling

```swift
enum RealTimeError: Error {
    case connectionFailed
    case messageSendFailed
    case authenticationFailed
}

class RealTimeService {
    private let manager: RealTimeManager
    
    init(config: RealTimeConfig) {
        self.manager = RealTimeManager(configuration: config)
        setupErrorHandling()
    }
    
    private func setupErrorHandling() {
        // Handle connection errors
        manager.onConnectionStatusChange { status in
            switch status {
            case .connected:
                print("Connected successfully")
            case .disconnected:
                print("Disconnected")
            case .connecting:
                print("Connecting...")
            case .reconnecting:
                print("Reconnecting...")
            }
        }
    }
    
    func sendMessage(_ text: String) async throws {
        let message = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: text.data(using: .utf8)!,
            timestamp: Date()
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            manager.send(message: message, priority: .normal) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
```

## Testing

### Unit Tests

```swift
import XCTest
@testable import RealTimeCommunication

class RealTimeManagerTests: XCTestCase {
    
    private var sut: RealTimeManager!
    private var mockConfig: RealTimeConfig!
    
    override func setUp() {
        super.setUp()
        
        mockConfig = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key"
        )
        
        sut = RealTimeManager(configuration: mockConfig)
    }
    
    func test_initialization() {
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.connectionStatus, .disconnected)
    }
    
    func test_connection() async throws {
        let result = try await sut.connect()
        XCTAssertEqual(result.status, .connected)
    }
}
```

### Integration Tests

```swift
class RealTimeIntegrationTests: XCTestCase {
    
    func test_messageWorkflow() async throws {
        let config = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key"
        )
        
        let manager = RealTimeManager(configuration: config)
        
        // Connect
        let connectionResult = try await manager.connect()
        XCTAssertEqual(connectionResult.status, .connected)
        
        // Send message
        let message = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: "Test message".data(using: .utf8)!,
            timestamp: Date()
        )
        
        let expectation = XCTestExpectation(description: "Message sent")
        manager.send(message: message, priority: .normal) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Message send failed: \(error)")
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Disconnect
        let disconnectionResult = await manager.disconnect()
        XCTAssertEqual(disconnectionResult.status, .disconnected)
    }
}
```

## Troubleshooting

### Common Issues

1. **Connection Failed**
   - Check server URL and API key
   - Verify network connectivity
   - Check server status

2. **Message Send Failed**
   - Ensure connection is established
   - Check message format
   - Verify message size limits

3. **Push Notifications Not Working**
   - Check device token registration
   - Verify APNs configuration
   - Check notification permissions

### Debug Mode

Enable debug logging for troubleshooting:

```swift
let debugConfig = RealTimeConfig(
    serverURL: "wss://your-server.com",
    apiKey: "your-api-key",
    logLevel: .debug,
    enableDebugLogging: true
)
```

### Performance Monitoring

Monitor framework performance:

```swift
// Get health metrics
let healthMetrics = realTimeManager.getHealthMetrics()
print("Latency: \(healthMetrics.latency)ms")
print("Throughput: \(healthMetrics.throughput) msg/s")
print("Error Rate: \(healthMetrics.errorRate)%")

// Get analytics
let analytics = realTimeManager.getAnalytics()
print("Total Events: \(analytics.totalEvents)")
print("Events Sent: \(analytics.eventsSent)")
```

## Next Steps

- Read the [API Reference](API/README.md) for detailed documentation
- Check out the [Examples](../Examples/) for sample applications
- Review the [Architecture Guide](Architecture/README.md) for system design
- Contribute to the project by reading the [Contributing Guide](../../CONTRIBUTING.md) 