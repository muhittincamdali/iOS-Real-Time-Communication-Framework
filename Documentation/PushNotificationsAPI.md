# Push Notifications API

<!-- TOC START -->
## Table of Contents
- [Push Notifications API](#push-notifications-api)
- [Overview](#overview)
- [Table of Contents](#table-of-contents)
- [PushNotificationManager](#pushnotificationmanager)
  - [Initialization](#initialization)
  - [Configuration](#configuration)
  - [Permission Management](#permission-management)
  - [Registration](#registration)
  - [Event Handling](#event-handling)
- [PushNotificationConfiguration](#pushnotificationconfiguration)
  - [Properties](#properties)
  - [Example](#example)
- [APNsManager](#apnsmanager)
  - [Initialization](#initialization)
  - [Configuration](#configuration)
  - [Registration](#registration)
  - [Token Handling](#token-handling)
  - [Notification Handling](#notification-handling)
- [FCMManager](#fcmmanager)
  - [Initialization](#initialization)
  - [Configuration](#configuration)
  - [Registration](#registration)
  - [Token Management](#token-management)
  - [Sending Notifications](#sending-notifications)
  - [Topic Management](#topic-management)
- [RichNotificationManager](#richnotificationmanager)
  - [Initialization](#initialization)
  - [Configuration](#configuration)
  - [Creating Rich Notifications](#creating-rich-notifications)
  - [Notification Categories](#notification-categories)
- [NotificationAction](#notificationaction)
  - [Properties](#properties)
  - [Initialization](#initialization)
- [NotificationCategory](#notificationcategory)
  - [Properties](#properties)
  - [Initialization](#initialization)
- [PushNotificationError](#pushnotificationerror)
  - [Error Types](#error-types)
  - [Properties](#properties)
  - [Example](#example)
- [Complete Example](#complete-example)
<!-- TOC END -->


## Overview

The Push Notifications API provides comprehensive push notification capabilities for iOS applications, including Apple Push Notification service (APNs) and Firebase Cloud Messaging (FCM). This document covers all public interfaces, classes, and methods available in the Push Notifications module.

## Table of Contents

- [PushNotificationManager](#pushnotificationmanager)
- [PushNotificationConfiguration](#pushnotificationconfiguration)
- [APNsManager](#apnsmanager)
- [FCMManager](#fcmmmanager)
- [RichNotificationManager](#richnotificationmanager)
- [NotificationAction](#notificationaction)
- [NotificationCategory](#notificationcategory)
- [PushNotificationError](#pushnotificationerror)

## PushNotificationManager

The main push notification manager class that coordinates all push notification services.

### Initialization

```swift
let pushManager = PushNotificationManager()
```

### Configuration

```swift
func configure(_ configuration: PushNotificationConfiguration)
```

Configures the push notification manager with the specified configuration.

**Parameters:**
- `configuration`: The push notification configuration object

**Example:**
```swift
let config = PushNotificationConfiguration()
config.enableAPNs = true
config.enableFCM = true
config.enableRichNotifications = true
config.enableSilentNotifications = true

pushManager.configure(config)
```

### Permission Management

```swift
func requestPermissions(options: UNAuthorizationOptions, completion: @escaping (Result<Bool, PushNotificationError>) -> Void)
```

Requests push notification permissions from the user.

**Parameters:**
- `options`: The authorization options
- `completion`: Completion handler called with the permission result

**Example:**
```swift
pushManager.requestPermissions(options: [.alert, .badge, .sound]) { result in
    switch result {
    case .success(let granted):
        if granted {
            print("✅ Notification permissions granted")
            self.registerForNotifications()
        } else {
            print("❌ Notification permissions denied")
        }
    case .failure(let error):
        print("❌ Permission request failed: \(error)")
    }
}
```

```swift
func getNotificationSettings(completion: @escaping (UNNotificationSettings) -> Void)
```

Gets the current notification settings.

**Parameters:**
- `completion`: Completion handler called with the notification settings

**Example:**
```swift
pushManager.getNotificationSettings { settings in
    print("📱 Alert setting: \(settings.alertSetting)")
    print("📱 Badge setting: \(settings.badgeSetting)")
    print("📱 Sound setting: \(settings.soundSetting)")
    print("📱 Critical alert setting: \(settings.criticalAlertSetting)")
}
```

### Registration

```swift
func registerForAPNs(completion: @escaping (Result<String, PushNotificationError>) -> Void)
```

Registers for Apple Push Notification service.

**Parameters:**
- `completion`: Completion handler called with the registration result

**Example:**
```swift
pushManager.registerForAPNs { result in
    switch result {
    case .success(let deviceToken):
        print("✅ APNs registered: \(deviceToken)")
        self.sendTokenToServer(deviceToken)
    case .failure(let error):
        print("❌ APNs registration failed: \(error)")
    }
}
```

```swift
func registerForFCM(completion: @escaping (Result<String, PushNotificationError>) -> Void)
```

Registers for Firebase Cloud Messaging.

**Parameters:**
- `completion`: Completion handler called with the registration result

**Example:**
```swift
pushManager.registerForFCM { result in
    switch result {
    case .success(let token):
        print("✅ FCM registered: \(token)")
        self.sendFCMTokenToServer(token)
    case .failure(let error):
        print("❌ FCM registration failed: \(error)")
    }
}
```

### Event Handling

```swift
func onForegroundNotification(_ handler: @escaping (UNNotification) -> Void)
```

Sets up a handler for foreground notifications.

**Parameters:**
- `handler`: Closure called when a notification is received in the foreground

**Example:**
```swift
pushManager.onForegroundNotification { notification in
    print("📱 Foreground notification: \(notification)")
    
    // Handle notification data
    if let messageId = notification.userInfo["messageId"] {
        print("Message ID: \(messageId)")
    }
}
```

```swift
func onBackgroundNotification(_ handler: @escaping (UNNotification) -> UIBackgroundFetchResult)
```

Sets up a handler for background notifications.

**Parameters:**
- `handler`: Closure called when a notification is received in the background

**Example:**
```swift
pushManager.onBackgroundNotification { notification in
    print("🔄 Background notification: \(notification)")
    
    // Process background notification
    self.processBackgroundNotification(notification)
    
    return .newData
}
```

```swift
func onNotificationTapped(_ handler: @escaping (UNNotification) -> Void)
```

Sets up a handler for notification taps.

**Parameters:**
- `handler`: Closure called when a notification is tapped

**Example:**
```swift
pushManager.onNotificationTapped { notification in
    print("👆 Notification tapped: \(notification)")
    
    // Navigate to specific screen
    if let messageId = notification.userInfo["messageId"] {
        self.navigateToMessage(messageId)
    }
}
```

## PushNotificationConfiguration

Configuration class for push notification settings.

### Properties

```swift
var enableAPNs: Bool
```

Whether to enable Apple Push Notification service.

```swift
var enableFCM: Bool
```

Whether to enable Firebase Cloud Messaging.

```swift
var enableRichNotifications: Bool
```

Whether to enable rich notifications.

```swift
var enableSilentNotifications: Bool
```

Whether to enable silent notifications.

```swift
var enableBadge: Bool
```

Whether to enable badge management.

```swift
var enableSound: Bool
```

Whether to enable sound notifications.

```swift
var enableAlert: Bool
```

Whether to enable alert notifications.

```swift
var enableCriticalAlerts: Bool
```

Whether to enable critical alerts.

```swift
var enableProvisional: Bool
```

Whether to enable provisional notifications.

```swift
var enableAnnouncements: Bool
```

Whether to enable announcement notifications.

### Example

```swift
let config = PushNotificationConfiguration()
config.enableAPNs = true
config.enableFCM = true
config.enableRichNotifications = true
config.enableSilentNotifications = true
config.enableBadge = true
config.enableSound = true
config.enableAlert = true
config.enableCriticalAlerts = false
config.enableProvisional = false
config.enableAnnouncements = false
```

## APNsManager

Manages Apple Push Notification service operations.

### Initialization

```swift
let apnsManager = APNsManager()
```

### Configuration

```swift
func configure(_ configuration: APNsConfiguration)
```

Configures the APNs manager.

**Parameters:**
- `configuration`: The APNs configuration object

**Example:**
```swift
let apnsConfig = APNsConfiguration()
apnsConfig.enableNotifications = true
apnsConfig.enableBadge = true
apnsConfig.enableSound = true
apnsConfig.enableAlert = true
apnsConfig.environment = .production

apnsManager.configure(apnsConfig)
```

### Registration

```swift
func registerForNotifications(completion: @escaping (Result<String, PushNotificationError>) -> Void)
```

Registers for APNs notifications.

**Parameters:**
- `completion`: Completion handler called with the registration result

**Example:**
```swift
apnsManager.registerForNotifications { result in
    switch result {
    case .success(let deviceToken):
        print("✅ APNs registered: \(deviceToken)")
    case .failure(let error):
        print("❌ APNs registration failed: \(error)")
    }
}
```

### Token Handling

```swift
func setDeviceToken(_ deviceToken: Data)
```

Sets the device token for APNs.

**Parameters:**
- `deviceToken`: The device token data

**Example:**
```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("📱 Device token: \(tokenString)")
    
    apnsManager.setDeviceToken(deviceToken)
}
```

### Notification Handling

```swift
func onNotificationReceived(_ handler: @escaping (UNNotification) -> Void)
```

Sets up a handler for incoming notifications.

**Parameters:**
- `handler`: Closure called when a notification is received

**Example:**
```swift
apnsManager.onNotificationReceived { notification in
    print("📱 Received notification: \(notification)")
}
```

```swift
func onPermissionChanged(_ handler: @escaping (Bool) -> Void)
```

Sets up a handler for permission changes.

**Parameters:**
- `handler`: Closure called when notification permissions change

**Example:**
```swift
apnsManager.onPermissionChanged { granted in
    if granted {
        print("✅ Notification permissions granted")
    } else {
        print("❌ Notification permissions denied")
    }
}
```

## FCMManager

Manages Firebase Cloud Messaging operations.

### Initialization

```swift
let fcmManager = FCMManager()
```

### Configuration

```swift
func configure(_ configuration: FCMConfiguration)
```

Configures the FCM manager.

**Parameters:**
- `configuration`: The FCM configuration object

**Example:**
```swift
let fcmConfig = FCMConfiguration()
fcmConfig.enableNotifications = true
fcmConfig.enableDataMessages = true
fcmConfig.enableBackgroundMessages = true
fcmConfig.enableAnalytics = true

fcmManager.configure(fcmConfig)
```

### Registration

```swift
func registerForNotifications(completion: @escaping (Result<String, PushNotificationError>) -> Void)
```

Registers for FCM notifications.

**Parameters:**
- `completion`: Completion handler called with the registration result

**Example:**
```swift
fcmManager.registerForNotifications { result in
    switch result {
    case .success(let token):
        print("✅ FCM registered: \(token)")
    case .failure(let error):
        print("❌ FCM registration failed: \(error)")
    }
}
```

### Token Management

```swift
func onTokenRefresh(_ handler: @escaping (String) -> Void)
```

Sets up a handler for token refresh events.

**Parameters:**
- `handler`: Closure called when the FCM token is refreshed

**Example:**
```swift
fcmManager.onTokenRefresh { newToken in
    print("🔄 FCM token refreshed: \(newToken)")
    self.updateFCMTokenOnServer(newToken)
}
```

### Sending Notifications

```swift
func sendNotification(_ notification: FCMPushNotification, to token: String, completion: @escaping (Result<Void, PushNotificationError>) -> Void)
```

Sends a push notification to a specific device.

**Parameters:**
- `notification`: The push notification
- `token`: The device token
- `completion`: Completion handler called with the send result

**Example:**
```swift
let notification = FCMPushNotification(
    title: "New Message",
    body: "You have a new message",
    data: ["messageId": "123"]
)

fcmManager.sendNotification(notification, to: "device_token") { result in
    switch result {
    case .success:
        print("✅ Notification sent")
    case .failure(let error):
        print("❌ Notification failed: \(error)")
    }
}
```

```swift
func sendNotificationToTopic(_ notification: FCMPushNotification, topic: String, completion: @escaping (Result<Void, PushNotificationError>) -> Void)
```

Sends a push notification to a topic.

**Parameters:**
- `notification`: The push notification
- `topic`: The topic name
- `completion`: Completion handler called with the send result

**Example:**
```swift
fcmManager.sendNotificationToTopic(notification, topic: "news") { result in
    switch result {
    case .success:
        print("✅ Topic notification sent")
    case .failure(let error):
        print("❌ Topic notification failed: \(error)")
    }
}
```

### Topic Management

```swift
func subscribeToTopic(_ topic: String, completion: @escaping (Result<Void, PushNotificationError>) -> Void)
```

Subscribes to a topic.

**Parameters:**
- `topic`: The topic name
- `completion`: Completion handler called with the subscription result

**Example:**
```swift
fcmManager.subscribeToTopic("news") { result in
    switch result {
    case .success:
        print("✅ Subscribed to news topic")
    case .failure(let error):
        print("❌ Topic subscription failed: \(error)")
    }
}
```

```swift
func unsubscribeFromTopic(_ topic: String, completion: @escaping (Result<Void, PushNotificationError>) -> Void)
```

Unsubscribes from a topic.

**Parameters:**
- `topic`: The topic name
- `completion`: Completion handler called with the unsubscription result

**Example:**
```swift
fcmManager.unsubscribeFromTopic("news") { result in
    switch result {
    case .success:
        print("✅ Unsubscribed from news topic")
    case .failure(let error):
        print("❌ Topic unsubscription failed: \(error)")
    }
}
```

## RichNotificationManager

Manages rich notification features.

### Initialization

```swift
let richNotificationManager = RichNotificationManager()
```

### Configuration

```swift
func configure(_ configuration: RichNotificationConfiguration)
```

Configures the rich notification manager.

**Parameters:**
- `configuration`: The rich notification configuration object

**Example:**
```swift
let richConfig = RichNotificationConfiguration()
richConfig.enableRichContent = true
richConfig.enableMediaAttachments = true
richConfig.enableCustomActions = true

richNotificationManager.configure(richConfig)
```

### Creating Rich Notifications

```swift
func sendRichNotification(_ notification: RichNotification, to token: String, completion: @escaping (Result<Void, PushNotificationError>) -> Void)
```

Sends a rich notification to a specific device.

**Parameters:**
- `notification`: The rich notification
- `token`: The device token
- `completion`: Completion handler called with the send result

**Example:**
```swift
let richNotification = RichNotification(
    title: "New Message",
    subtitle: "From John Doe",
    body: "You have a new message",
    attachments: [
        NotificationAttachment(
            url: "https://example.com/avatar.jpg",
            type: "image"
        )
    ],
    actions: [
        NotificationAction(
            identifier: "reply",
            title: "Reply",
            options: [.foreground]
        ),
        NotificationAction(
            identifier: "mark_read",
            title: "Mark as Read",
            options: [.destructive]
        )
    ]
)

richNotificationManager.sendRichNotification(richNotification, to: "device_token") { result in
    switch result {
    case .success:
        print("✅ Rich notification sent")
    case .failure(let error):
        print("❌ Rich notification failed: \(error)")
    }
}
```

### Notification Categories

```swift
func registerNotificationCategories(_ categories: [NotificationCategory])
```

Registers notification categories.

**Parameters:**
- `categories`: Array of notification categories

**Example:**
```swift
let messageCategory = NotificationCategory(
    identifier: "message",
    actions: [
        NotificationAction(
            identifier: "reply",
            title: "Reply",
            options: [.foreground]
        ),
        NotificationAction(
            identifier: "mark_read",
            title: "Mark as Read",
            options: [.destructive]
        )
    ]
)

let callCategory = NotificationCategory(
    identifier: "call",
    actions: [
        NotificationAction(
            identifier: "answer",
            title: "Answer",
            options: [.foreground]
        ),
        NotificationAction(
            identifier: "decline",
            title: "Decline",
            options: [.destructive]
        )
    ]
)

richNotificationManager.registerNotificationCategories([messageCategory, callCategory])
```

## NotificationAction

Represents a notification action.

### Properties

```swift
var identifier: String
```

The action identifier.

```swift
var title: String
```

The action title.

```swift
var options: UNNotificationActionOptions
```

The action options.

```swift
var response: String?
```

The action response text.

### Initialization

```swift
init(identifier: String, title: String, options: UNNotificationActionOptions)
```

Creates a new notification action.

**Parameters:**
- `identifier`: The action identifier
- `title`: The action title
- `options`: The action options

**Example:**
```swift
let action = NotificationAction(
    identifier: "reply",
    title: "Reply",
    options: [.foreground]
)
```

## NotificationCategory

Represents a notification category.

### Properties

```swift
var identifier: String
```

The category identifier.

```swift
var actions: [NotificationAction]
```

The category actions.

### Initialization

```swift
init(identifier: String, actions: [NotificationAction])
```

Creates a new notification category.

**Parameters:**
- `identifier`: The category identifier
- `actions`: The category actions

**Example:**
```swift
let category = NotificationCategory(
    identifier: "message",
    actions: [
        NotificationAction(identifier: "reply", title: "Reply", options: [.foreground]),
        NotificationAction(identifier: "mark_read", title: "Mark as Read", options: [.destructive])
    ]
)
```

## PushNotificationError

Represents push notification errors.

### Error Types

```swift
enum PushNotificationError: Error {
    case permissionDenied
    case registrationFailed(String)
    case tokenGenerationFailed(String)
    case notificationSendFailed(String)
    case invalidConfiguration(String)
    case networkError(Error)
    case serverError(String)
    case deviceNotSupported
    case tokenInvalid(String)
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
pushManager.onError { error in
    switch error {
    case .permissionDenied:
        print("❌ Notification permissions denied")
    case .registrationFailed(let reason):
        print("❌ Registration failed: \(reason)")
    case .tokenGenerationFailed(let reason):
        print("❌ Token generation failed: \(reason)")
    case .notificationSendFailed(let reason):
        print("❌ Notification send failed: \(reason)")
    case .invalidConfiguration(let detail):
        print("❌ Invalid configuration: \(detail)")
    case .networkError(let underlyingError):
        print("❌ Network error: \(underlyingError)")
    case .serverError(let message):
        print("❌ Server error: \(message)")
    case .deviceNotSupported:
        print("❌ Device not supported")
    case .tokenInvalid(let reason):
        print("❌ Token invalid: \(reason)")
    }
}
```

## Complete Example

```swift
import RealTimeCommunication
import SwiftUI
import UserNotifications

class PushNotificationManager: ObservableObject {
    private let pushManager = PushNotificationManager()
    
    @Published var isRegistered = false
    @Published var notificationSettings: UNNotificationSettings?
    @Published var badgeCount = 0
    
    init() {
        setupPushNotifications()
    }
    
    private func setupPushNotifications() {
        let config = PushNotificationConfiguration()
        config.enableAPNs = true
        config.enableFCM = true
        config.enableRichNotifications = true
        config.enableSilentNotifications = true
        
        pushManager.configure(config)
        
        // Handle notification registration
        pushManager.onRegistrationSuccess { [weak self] in
            DispatchQueue.main.async {
                self?.isRegistered = true
            }
        }
        
        // Handle incoming notifications
        pushManager.onForegroundNotification { [weak self] notification in
            DispatchQueue.main.async {
                self?.handleIncomingNotification(notification)
            }
        }
        
        // Handle notification taps
        pushManager.onNotificationTapped { [weak self] notification in
            DispatchQueue.main.async {
                self?.handleNotificationTap(notification)
            }
        }
    }
    
    func requestPermissions() {
        pushManager.requestPermissions(options: [.alert, .badge, .sound]) { result in
            switch result {
            case .success(let granted):
                if granted {
                    self.registerForNotifications()
                }
            case .failure(let error):
                print("❌ Permission request failed: \(error)")
            }
        }
    }
    
    private func registerForNotifications() {
        // Register for APNs
        pushManager.registerForAPNs { result in
            switch result {
            case .success(let deviceToken):
                print("✅ APNs registered: \(deviceToken)")
                self.sendTokenToServer(deviceToken)
            case .failure(let error):
                print("❌ APNs registration failed: \(error)")
            }
        }
        
        // Register for FCM
        pushManager.registerForFCM { result in
            switch result {
            case .success(let token):
                print("✅ FCM registered: \(token)")
                self.sendFCMTokenToServer(token)
            case .failure(let error):
                print("❌ FCM registration failed: \(error)")
            }
        }
    }
    
    private func sendTokenToServer(_ token: String) {
        // Send token to your server
        let tokenData = [
            "deviceToken": token,
            "platform": "ios",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        ]
        
        // API call to your server
        // sendTokenToServer(tokenData)
    }
    
    private func sendFCMTokenToServer(_ token: String) {
        // Send FCM token to your server
        let tokenData = [
            "fcmToken": token,
            "platform": "ios"
        ]
        
        // API call to your server
        // sendFCMTokenToServer(tokenData)
    }
    
    private func handleIncomingNotification(_ notification: UNNotification) {
        print("📱 Received notification: \(notification.request.content.title)")
        
        // Handle notification data
        let userInfo = notification.request.content.userInfo
        
        if let messageId = userInfo["messageId"] as? String {
            // Handle new message
            handleNewMessage(messageId)
        }
        
        if let callId = userInfo["callId"] as? String {
            // Handle incoming call
            handleIncomingCall(callId)
        }
    }
    
    private func handleNotificationTap(_ notification: UNNotification) {
        print("👆 Notification tapped: \(notification.request.content.title)")
        
        let userInfo = notification.request.content.userInfo
        
        // Navigate based on notification type
        if let messageId = userInfo["messageId"] as? String {
            navigateToMessage(messageId)
        }
        
        if let callId = userInfo["callId"] as? String {
            navigateToCall(callId)
        }
    }
    
    private func handleNewMessage(_ messageId: String) {
        // Handle new message notification
        print("💬 New message: \(messageId)")
        
        // Update UI or fetch message details
    }
    
    private func handleIncomingCall(_ callId: String) {
        // Handle incoming call notification
        print("📞 Incoming call: \(callId)")
        
        // Show call UI
    }
    
    private func navigateToMessage(_ messageId: String) {
        // Navigate to message detail
        print("🧭 Navigate to message: \(messageId)")
    }
    
    private func navigateToCall(_ callId: String) {
        // Navigate to call screen
        print("🧭 Navigate to call: \(callId)")
    }
    
    func updateBadgeCount(_ count: Int) {
        pushManager.setBadgeCount(count) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.badgeCount = count
                }
            case .failure(let error):
                print("❌ Badge update failed: \(error)")
            }
        }
    }
    
    func clearBadge() {
        pushManager.clearBadge { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.badgeCount = 0
                }
            case .failure(let error):
                print("❌ Badge clearing failed: \(error)")
            }
        }
    }
}

struct PushNotificationView: View {
    @StateObject private var pushManager = PushNotificationManager()
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Status
                VStack {
                    HStack {
                        Circle()
                            .fill(pushManager.isRegistered ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text(pushManager.isRegistered ? "Registered" : "Not Registered")
                    }
                    
                    if let settings = pushManager.notificationSettings {
                        VStack(alignment: .leading) {
                            Text("Alert: \(settings.alertSetting.description)")
                            Text("Badge: \(settings.badgeSetting.description)")
                            Text("Sound: \(settings.soundSetting.description)")
                        }
                        .font(.caption)
                        .padding()
                    }
                }
                
                // Badge count
                HStack {
                    Text("Badge Count:")
                    Text("\(pushManager.badgeCount)")
                        .font(.title2)
                        .bold()
                }
                
                // Actions
                VStack(spacing: 10) {
                    Button("Request Permissions") {
                        pushManager.requestPermissions()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Update Badge (+1)") {
                        pushManager.updateBadgeCount(pushManager.badgeCount + 1)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Clear Badge") {
                        pushManager.clearBadge()
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Push Notifications")
            .alert("Permission Required", isPresented: $showingPermissionAlert) {
                Button("Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enable notifications in Settings to receive updates.")
            }
        }
        .onAppear {
            // Check current settings
            pushManager.getNotificationSettings { settings in
                DispatchQueue.main.async {
                    pushManager.notificationSettings = settings
                }
            }
        }
    }
}

extension UNNotificationSetting {
    var description: String {
        switch self {
        case .enabled:
            return "Enabled"
        case .disabled:
            return "Disabled"
        case .notSupported:
            return "Not Supported"
        @unknown default:
            return "Unknown"
        }
    }
}
```

This comprehensive API documentation covers all aspects of the Push Notifications module in the iOS Real-Time Communication Framework. For more examples and advanced usage, refer to the Push Notifications Guide and other documentation.
