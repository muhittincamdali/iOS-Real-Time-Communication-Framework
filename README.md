# iOS Real-Time Communication Framework

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9+-F05138?style=flat&logo=swift&logoColor=white" alt="Swift"></a>
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/iOS-15.0+-000000?style=flat&logo=apple&logoColor=white" alt="iOS"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License"></a>
</p>

<p align="center">
  <b>Real-time messaging with WebSocket, push notifications, and presence tracking.</b>
</p>

---

## Features

- **WebSocket** — Real-time bidirectional communication
- **Push Notifications** — APNs integration
- **Presence** — Online/offline status tracking
- **Typing Indicators** — Real-time typing status
- **Message Queue** — Offline message queuing

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Real-Time-Communication-Framework.git", from: "1.0.0")
]
```

## Quick Start

```swift
import RealTimeCommunication

let rtc = RTCClient(url: "wss://api.example.com/ws")

// Connect
try await rtc.connect()

// Send message
try await rtc.send(ChatMessage(text: "Hello!", roomId: "room123"))

// Receive messages
for await message in rtc.messages {
    print("Received: \(message.text)")
}

// Presence
rtc.updatePresence(.online)

// Typing indicator
rtc.sendTypingIndicator(roomId: "room123")
```

## Push Notifications

```swift
// Register for push
let token = try await rtc.registerForPush()

// Handle notification
rtc.handleNotification(userInfo) { message in
    showNotification(message)
}
```

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## License

MIT License. See [LICENSE](LICENSE).

## Author

**Muhittin Camdali** — [@muhittincamdali](https://github.com/muhittincamdali)
