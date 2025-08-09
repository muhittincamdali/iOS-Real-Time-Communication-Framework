# Push Notifications Guide

<!-- TOC START -->
## Table of Contents
- [Push Notifications Guide](#push-notifications-guide)
- [Overview](#overview)
- [Table of Contents](#table-of-contents)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Basic Setup](#basic-setup)
- [APNs Setup](#apns-setup)
  - [Apple Developer Setup](#apple-developer-setup)
  - [APNs Configuration](#apns-configuration)
  - [APNs Registration](#apns-registration)
- [FCM Setup](#fcm-setup)
  - [Firebase Setup](#firebase-setup)
  - [FCM Configuration](#fcm-configuration)
  - [FCM Registration](#fcm-registration)
- [Notification Registration](#notification-registration)
  - [Permission Request](#permission-request)
  - [Custom Registration](#custom-registration)
- [Notification Handling](#notification-handling)
  - [Foreground Notifications](#foreground-notifications)
  - [Background Notifications](#background-notifications)
  - [Notification Tap Handling](#notification-tap-handling)
- [Rich Notifications](#rich-notifications)
  - [Rich Notification Setup](#rich-notification-setup)
  - [Creating Rich Notifications](#creating-rich-notifications)
  - [Notification Categories](#notification-categories)
- [Silent Notifications](#silent-notifications)
  - [Silent Notification Setup](#silent-notification-setup)
  - [Handling Silent Notifications](#handling-silent-notifications)
- [Notification Actions](#notification-actions)
  - [Action Handling](#action-handling)
  - [Custom Actions](#custom-actions)
- [Badge Management](#badge-management)
  - [Badge Operations](#badge-operations)
  - [Badge Synchronization](#badge-synchronization)
- [Security](#security)
  - [Token Security](#token-security)
  - [Certificate Pinning](#certificate-pinning)
- [Best Practices](#best-practices)
  - [1. Permission Management](#1-permission-management)
  - [2. Token Management](#2-token-management)
  - [3. Notification Content](#3-notification-content)
  - [4. Background Processing](#4-background-processing)
  - [5. User Experience](#5-user-experience)
  - [6. Testing](#6-testing)
- [Examples](#examples)
  - [Complete Push Notification Implementation](#complete-push-notification-implementation)
<!-- TOC END -->


## Overview

The Push Notifications module provides comprehensive push notification capabilities for iOS applications, including Apple Push Notification service (APNs) and Firebase Cloud Messaging (FCM). This guide covers everything you need to know about implementing push notifications in your iOS app.

## Table of Contents

- [Getting Started](#getting-started)
- [APNs Setup](#apns-setup)
- [FCM Setup](#fcm-setup)
- [Notification Registration](#notification-registration)
- [Notification Handling](#notification-handling)
- [Rich Notifications](#rich-notifications)
- [Silent Notifications](#silent-notifications)
- [Notification Actions](#notification-actions)
- [Badge Management](#badge-management)
- [Security](#security)
- [Best Practices](#best-practices)

## Getting Started

### Prerequisites

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+
- Apple Developer Account
- Push notification certificates
- Firebase project (for FCM)

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

// Initialize push notification manager
let pushManager = PushNotificationManager()

// Configure push notifications
let config = PushNotificationConfiguration()
config.enableAPNs = true
config.enableFCM = true
config.enableRichNotifications = true
config.enableSilentNotifications = true

// Setup push notifications
pushManager.configure(config)
```

## APNs Setup

### Apple Developer Setup

1. **Create Push Certificate**
   - Go to Apple Developer Portal
   - Create App ID with push notifications
   - Generate push certificate
   - Download and install certificate

2. **Configure Xcode Project**
   - Enable push notifications capability
   - Add background modes
   - Configure notification entitlements

### APNs Configuration

```swift
// Configure APNs
let apnsConfig = APNsConfiguration()
apnsConfig.enableNotifications = true
apnsConfig.enableBadge = true
apnsConfig.enableSound = true
apnsConfig.enableAlert = true
apnsConfig.enableCriticalAlerts = false

// Environment settings
apnsConfig.environment = .production // or .sandbox
apnsConfig.bundleID = "com.yourcompany.yourapp"

// Certificate settings
apnsConfig.certificatePath = "path/to/certificate.p12"
apnsConfig.certificatePassword = "your-password"

pushManager.configureAPNs(apnsConfig)
```

### APNs Registration

```swift
// Register for APNs
pushManager.registerForAPNs { result in
    switch result {
    case .success(let deviceToken):
        print("✅ APNs registered: \(deviceToken)")
        
        // Send token to your server
        self.sendTokenToServer(deviceToken)
    case .failure(let error):
        print("❌ APNs registration failed: \(error)")
    }
}

// Handle device token
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("📱 Device token: \(tokenString)")
    
    // Send token to push manager
    pushManager.setDeviceToken(deviceToken)
}
```

## FCM Setup

### Firebase Setup

1. **Create Firebase Project**
   - Go to Firebase Console
   - Create new project
   - Add iOS app
   - Download GoogleService-Info.plist

2. **Configure Firebase**
   - Add GoogleService-Info.plist to project
   - Enable Cloud Messaging
   - Configure APNs authentication

### FCM Configuration

```swift
// Configure FCM
let fcmConfig = FCMConfiguration()
fcmConfig.enableNotifications = true
fcmConfig.enableDataMessages = true
fcmConfig.enableBackgroundMessages = true
fcmConfig.enableAnalytics = true

// APNs integration
fcmConfig.apnsToken = deviceToken
fcmConfig.apnsAuthKey = "path/to/AuthKey.p8"
fcmConfig.apnsKeyID = "your-key-id"
fcmConfig.apnsTeamID = "your-team-id"

pushManager.configureFCM(fcmConfig)
```

### FCM Registration

```swift
// Register for FCM
pushManager.registerForFCM { result in
    switch result {
    case .success(let token):
        print("✅ FCM token: \(token)")
        
        // Send token to your server
        self.sendFCMTokenToServer(token)
    case .failure(let error):
        print("❌ FCM registration failed: \(error)")
    }
}

// Handle FCM token refresh
pushManager.onFCMTokenRefresh { newToken in
    print("🔄 FCM token refreshed: \(newToken)")
    
    // Update token on your server
    self.updateFCMTokenOnServer(newToken)
}
```

## Notification Registration

### Permission Request

```swift
// Request notification permissions
pushManager.requestPermissions(options: [.alert, .badge, .sound]) { result in
    switch result {
    case .success(let granted):
        if granted {
            print("✅ Notification permissions granted")
            
            // Register for notifications
            self.registerForNotifications()
        } else {
            print("❌ Notification permissions denied")
        }
    case .failure(let error):
        print("❌ Permission request failed: \(error)")
    }
}

// Check current permissions
pushManager.getNotificationSettings { settings in
    print("📱 Alert setting: \(settings.alertSetting)")
    print("📱 Badge setting: \(settings.badgeSetting)")
    print("📱 Sound setting: \(settings.soundSetting)")
    print("📱 Critical alert setting: \(settings.criticalAlertSetting)")
}
```

### Custom Registration

```swift
// Custom registration with user preferences
let registrationOptions = NotificationRegistrationOptions()
registrationOptions.enableAlerts = true
registrationOptions.enableBadges = true
registrationOptions.enableSounds = true
registrationOptions.enableCriticalAlerts = false
registrationOptions.enableProvisional = false
registrationOptions.enableAnnouncements = false

pushManager.registerWithOptions(registrationOptions) { result in
    switch result {
    case .success(let granted):
        print("✅ Custom registration successful: \(granted)")
    case .failure(let error):
        print("❌ Custom registration failed: \(error)")
    }
}
```

## Notification Handling

### Foreground Notifications

```swift
// Handle foreground notifications
pushManager.onForegroundNotification { notification in
    print("📱 Foreground notification: \(notification)")
    
    // Handle notification data
    if let messageId = notification.userInfo["messageId"] as? String {
        print("Message ID: \(messageId)")
    }
    
    // Show custom UI
    self.showCustomNotificationUI(notification)
}

// Custom foreground presentation
pushManager.setForegroundPresentationOptions([.banner, .sound, .badge])
```

### Background Notifications

```swift
// Handle background notifications
pushManager.onBackgroundNotification { notification in
    print("🔄 Background notification: \(notification)")
    
    // Process background notification
    self.processBackgroundNotification(notification)
    
    return .newData
}

// Handle silent notifications
pushManager.onSilentNotification { notification in
    print("🔇 Silent notification: \(notification)")
    
    // Process silent notification
    self.processSilentNotification(notification)
    
    return .newData
}
```

### Notification Tap Handling

```swift
// Handle notification tap
pushManager.onNotificationTapped { notification in
    print("👆 Notification tapped: \(notification)")
    
    // Navigate to specific screen
    if let messageId = notification.userInfo["messageId"] as? String {
        self.navigateToMessage(messageId)
    }
    
    // Handle deep link
    if let deepLink = notification.userInfo["deepLink"] as? String {
        self.handleDeepLink(deepLink)
    }
}
```

## Rich Notifications

### Rich Notification Setup

```swift
// Configure rich notifications
let richConfig = RichNotificationConfiguration()
richConfig.enableRichContent = true
richConfig.enableMediaAttachments = true
richConfig.enableCustomActions = true
richConfig.enableCategoryActions = true

pushManager.configureRichNotifications(richConfig)
```

### Creating Rich Notifications

```swift
// Create rich notification
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

// Send rich notification
pushManager.sendRichNotification(richNotification, to: "user_token") { result in
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
// Create notification categories
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

// Register categories
pushManager.registerNotificationCategories([messageCategory, callCategory])
```

## Silent Notifications

### Silent Notification Setup

```swift
// Configure silent notifications
let silentConfig = SilentNotificationConfiguration()
silentConfig.enableSilentNotifications = true
silentConfig.enableBackgroundProcessing = true
silentConfig.enableDataSync = true

pushManager.configureSilentNotifications(silentConfig)
```

### Handling Silent Notifications

```swift
// Handle silent notifications
pushManager.onSilentNotification { notification in
    print("🔇 Silent notification: \(notification)")
    
    // Extract data
    guard let data = notification.userInfo["data"] as? [String: Any] else {
        return .noData
    }
    
    // Process data
    switch data["type"] as? String {
    case "message":
        self.processNewMessage(data)
    case "sync":
        self.syncData(data)
    case "update":
        self.updateContent(data)
    default:
        print("Unknown silent notification type")
    }
    
    return .newData
}
```

## Notification Actions

### Action Handling

```swift
// Handle notification actions
pushManager.onNotificationAction { action in
    print("👆 Action performed: \(action.identifier)")
    
    switch action.identifier {
    case "reply":
        self.handleReplyAction(action)
    case "mark_read":
        self.handleMarkReadAction(action)
    case "answer":
        self.handleAnswerCallAction(action)
    case "decline":
        self.handleDeclineCallAction(action)
    default:
        print("Unknown action: \(action.identifier)")
    }
}

// Handle reply action
private func handleReplyAction(_ action: NotificationAction) {
    guard let response = action.response else { return }
    
    print("💬 Reply: \(response)")
    
    // Send reply to server
    self.sendReplyToServer(response)
}
```

### Custom Actions

```swift
// Create custom actions
let customAction = NotificationAction(
    identifier: "custom_action",
    title: "Custom Action",
    options: [.foreground, .destructive],
    textInputButtonTitle: "Send",
    textInputPlaceholder: "Enter response..."
)

// Register custom action
pushManager.registerCustomAction(customAction)
```

## Badge Management

### Badge Operations

```swift
// Set app badge
pushManager.setBadgeCount(5) { result in
    switch result {
    case .success:
        print("✅ Badge set to 5")
    case .failure(let error):
        print("❌ Badge setting failed: \(error)")
    }
}

// Clear app badge
pushManager.clearBadge { result in
    switch result {
    case .success:
        print("✅ Badge cleared")
    case .failure(let error):
        print("❌ Badge clearing failed: \(error)")
    }
}

// Get current badge count
pushManager.getBadgeCount { count in
    print("📱 Current badge count: \(count)")
}
```

### Badge Synchronization

```swift
// Sync badge with server
pushManager.syncBadgeWithServer { result in
    switch result {
    case .success(let count):
        print("✅ Badge synced: \(count)")
    case .failure(let error):
        print("❌ Badge sync failed: \(error)")
    }
}

// Auto badge management
let badgeConfig = BadgeConfiguration()
badgeConfig.enableAutoBadge = true
badgeConfig.syncWithServer = true
badgeConfig.clearOnAppLaunch = true

pushManager.configureBadge(badgeConfig)
```

## Security

### Token Security

```swift
// Secure token storage
let securityConfig = NotificationSecurityConfiguration()
securityConfig.enableTokenEncryption = true
securityConfig.enableTokenValidation = true
securityConfig.enableCertificatePinning = true

pushManager.configureSecurity(securityConfig)
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

pushManager.configureCertificatePinning(pinningConfig)
```

## Best Practices

### 1. Permission Management

- Request permissions at appropriate times
- Explain why notifications are needed
- Handle permission denial gracefully
- Provide alternative notification methods

### 2. Token Management

- Store tokens securely
- Send tokens to your server immediately
- Handle token refresh properly
- Validate tokens before use

### 3. Notification Content

- Keep notifications concise
- Use clear, actionable language
- Include relevant data
- Test on different devices

### 4. Background Processing

- Handle silent notifications efficiently
- Minimize background processing time
- Use background app refresh appropriately
- Handle network failures gracefully

### 5. User Experience

- Respect user preferences
- Provide notification settings
- Handle notification taps properly
- Implement proper navigation

### 6. Testing

- Test on real devices
- Test different iOS versions
- Test network conditions
- Test notification actions

## Examples

### Complete Push Notification Implementation

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

This comprehensive guide covers all aspects of push notification implementation in the iOS Real-Time Communication Framework. For more advanced features and examples, refer to the API documentation and other guides.
