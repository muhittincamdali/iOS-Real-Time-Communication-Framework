# Getting Started with iOS Real-Time Communication Framework

Welcome to the iOS Real-Time Communication Framework! This guide will help you get started with integrating real-time communication features into your iOS applications.

## 📋 Prerequisites

Before you begin, ensure you have the following:

- **Xcode**: 15.0 or later
- **iOS**: 15.0+ deployment target
- **Swift**: 5.9 or later
- **Git**: Latest version
- **GitHub CLI**: For repository operations

## 🚀 Installation

### Swift Package Manager (Recommended)

1. **Add the dependency** to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Real-Time-Communication-Framework.git", from: "2.1.0")
]
```

2. **Add the target** to your app:

```swift
targets: [
    .target(
        name: "YourApp",
        dependencies: ["RealTimeCommunication"]
    )
]
```

### CocoaPods

1. **Add to your `Podfile`**:

```ruby
pod 'iOSRealTimeCommunicationFramework', '~> 2.1.0'
```

2. **Install the pod**:

```bash
pod install
```

## 🔧 Basic Setup

### 1. Import the Framework

```swift
import RealTimeCommunication
```

### 2. Initialize the Communication Manager

```swift
let communicationManager = RealTimeCommunicationManager()
```

### 3. Configure Basic Settings

```swift
var config = CommunicationConfiguration()
config.webSocketEnabled = true
config.pushNotificationEnabled = true
config.messageQueueEnabled = true
config.autoReconnect = true
config.timeout = 30.0
config.maxRetries = 3

communicationManager.configuration = config
```

## 📱 Quick Examples

### WebSocket Connection

```swift
// Establish WebSocket connection
communicationManager.establishWebSocketConnection(
    to: URL(string: "wss://your-server.com/ws")!
) { result in
    switch result {
    case .success(let connection):
        print("Connected: \(connection.id)")
    case .failure(let error):
        print("Connection failed: \(error)")
    }
}
```

### Send Real-Time Message

```swift
let message = RealTimeMessage(
    title: "Hello",
    body: "This is a real-time message",
    data: "Hello World".data(using: .utf8)!,
    type: .text,
    senderId: "user123"
)

communicationManager.sendRealTimeMessage(message, to: ["recipient1"]) { result in
    switch result {
    case .success:
        print("Message sent successfully")
    case .failure(let error):
        print("Message failed: \(error)")
    }
}
```

### Push Notifications

```swift
// Register for push notifications
communicationManager.registerForPushNotifications { result in
    switch result {
    case .success(let deviceToken):
        print("Registered: \(deviceToken)")
    case .failure(let error):
        print("Registration failed: \(error)")
    }
}

// Send push notification
let notification = PushNotification(
    id: UUID().uuidString,
    title: "New Message",
    body: "You have a new message",
    recipientId: "user456",
    type: .message
)

communicationManager.sendPushNotification(notification) { result in
    // Handle result
}
```

## 🏗️ Architecture Overview

The framework follows Clean Architecture principles:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                      │
│  (Your iOS App UI)                                        │
├─────────────────────────────────────────────────────────────┤
│                    Business Logic Layer                    │
│  (RealTimeCommunicationManager)                           │
├─────────────────────────────────────────────────────────────┤
│                    Data Layer                             │
│  (WebSocket, Push Notifications, Message Queue)          │
└─────────────────────────────────────────────────────────────┘
```

### Core Components

- **RealTimeCommunicationManager**: Main orchestrator
- **WebSocketManager**: Handles WebSocket connections
- **PushNotificationManager**: Manages push notifications
- **MessageQueue**: Handles message queuing
- **CommunicationAnalytics**: Provides analytics

## 🔒 Security Configuration

### SSL/TLS Configuration

```swift
// Configure SSL/TLS settings
let sslConfig = SSLConfiguration(
    certificatePath: "path/to/certificate.p12",
    password: "certificate-password"
)

communicationManager.configureSSL(sslConfig)
```

### Authentication

```swift
// Add authentication headers
let headers = [
    "Authorization": "Bearer your-token",
    "X-API-Key": "your-api-key"
]

communicationManager.establishWebSocketConnection(
    to: URL(string: "wss://api.example.com/ws")!,
    headers: headers
) { result in
    // Handle connection result
}
```

## 📊 Analytics Integration

### Custom Analytics

```swift
class CustomAnalytics: CommunicationAnalytics {
    func recordWebSocketConnectionEstablished(url: URL) {
        // Send to your analytics service
        Analytics.track("websocket_connected", properties: ["url": url.absoluteString])
    }
    
    func recordRealTimeMessageSent(messageId: String, recipientCount: Int) {
        Analytics.track("message_sent", properties: [
            "message_id": messageId,
            "recipient_count": recipientCount
        ])
    }
    
    // Implement other analytics methods...
}

// Initialize with analytics
let analytics = CustomAnalytics()
let manager = RealTimeCommunicationManager(analytics: analytics)
```

## 🧪 Testing

### Unit Tests

```swift
import XCTest
@testable import RealTimeCommunication

class CommunicationManagerTests: XCTestCase {
    var manager: RealTimeCommunicationManager!
    
    override func setUp() {
        super.setUp()
        manager = RealTimeCommunicationManager()
    }
    
    func testWebSocketConnection() {
        let expectation = XCTestExpectation(description: "WebSocket connection")
        
        manager.establishWebSocketConnection(
            to: URL(string: "wss://echo.websocket.org")!
        ) { result in
            XCTAssertTrue(result.isSuccess)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
```

### Performance Tests

```swift
func testMessageSendingPerformance() {
    let message = RealTimeMessage(
        title: "Performance Test",
        body: "Performance test message",
        data: "Test".data(using: .utf8)!,
        type: .text,
        senderId: "test"
    )
    
    measure {
        let expectation = XCTestExpectation(description: "Performance test")
        
        manager.sendRealTimeMessage(message, to: ["test"]) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
```

## 🔧 Configuration Options

### Communication Configuration

```swift
var config = CommunicationConfiguration()

// WebSocket settings
config.webSocketEnabled = true
config.autoReconnect = true
config.timeout = 30.0
config.maxRetries = 3

// Push notification settings
config.pushNotificationEnabled = true

// Message queue settings
config.messageQueueEnabled = true

communicationManager.configuration = config
```

### Advanced Configuration

```swift
// Custom WebSocket configuration
let wsConfig = WebSocketConfiguration(
    url: URL(string: "wss://api.example.com/ws")!,
    headers: ["Authorization": "Bearer token"],
    timeout: 30.0,
    maxRetries: 3
)

// Custom push notification configuration
let pushConfig = PushNotificationConfiguration(
    appId: "com.example.app",
    certificatePath: "path/to/certificate.p12",
    environment: .production
)

// Apply configurations
communicationManager.configureWebSocket(wsConfig)
communicationManager.configurePushNotifications(pushConfig)
```

## 📱 iOS Integration

### App Delegate Setup

```swift
import UIKit
import RealTimeCommunication

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var communicationManager: RealTimeCommunicationManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize communication manager
        communicationManager = RealTimeCommunicationManager()
        
        // Configure push notifications
        communicationManager.registerForPushNotifications { result in
            switch result {
            case .success(let deviceToken):
                print("Push notification registered: \(deviceToken)")
            case .failure(let error):
                print("Push notification registration failed: \(error)")
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Handle device token
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device token: \(tokenString)")
    }
}
```

### SwiftUI Integration

```swift
import SwiftUI
import RealTimeCommunication

struct ContentView: View {
    @StateObject private var communicationManager = RealTimeCommunicationManager()
    @State private var isConnected = false
    
    var body: some View {
        VStack {
            Text(isConnected ? "Connected" : "Disconnected")
                .foregroundColor(isConnected ? .green : .red)
            
            Button("Connect") {
                connectToServer()
            }
        }
        .onAppear {
            setupCommunication()
        }
    }
    
    private func setupCommunication() {
        // Setup communication manager
        communicationManager.establishWebSocketConnection(
            to: URL(string: "wss://your-server.com/ws")!
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    isConnected = true
                case .failure:
                    isConnected = false
                }
            }
        }
    }
    
    private func connectToServer() {
        // Implementation
    }
}
```

## 🚀 Next Steps

1. **Explore Examples**: Check out the [Examples](Examples/) directory for complete sample applications
2. **Read Documentation**: Browse the [Documentation](Documentation/) for detailed guides
3. **Run Tests**: Execute the test suite to verify everything works
4. **Join Community**: Participate in [GitHub Discussions](https://github.com/muhittincamdali/iOS-Real-Time-Communication-Framework/discussions)

## 📞 Support

- **Documentation**: [Full Documentation](Documentation/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Real-Time-Communication-Framework/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Real-Time-Communication-Framework/discussions)

---

**Happy coding! 🚀** 