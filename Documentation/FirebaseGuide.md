# Firebase Guide

## Overview

The Firebase module provides comprehensive Firebase integration for iOS applications, including Realtime Database, Cloud Messaging, Authentication, and Analytics. This guide covers everything you need to know about implementing Firebase features in your iOS app.

## Table of Contents

- [Getting Started](#getting-started)
- [Firebase Setup](#firebase-setup)
- [Realtime Database](#realtime-database)
- [Cloud Messaging](#cloud-messaging)
- [Authentication](#authentication)
- [Analytics](#analytics)
- [Storage](#storage)
- [Functions](#functions)
- [Performance](#performance)
- [Security](#security)
- [Best Practices](#best-practices)

## Getting Started

### Prerequisites

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+
- Firebase project
- GoogleService-Info.plist

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

// Initialize Firebase manager
let firebaseManager = FirebaseManager()

// Configure Firebase
let config = FirebaseConfiguration()
config.projectID = "your-project-id"
config.enableAnalytics = true
config.enableMessaging = true
config.enableDatabase = true

// Setup Firebase
firebaseManager.configure(config)
```

## Firebase Setup

### Project Configuration

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or select existing one
   - Enable required services

2. **Add iOS App**
   - Click "Add app" and select iOS
   - Enter your bundle identifier
   - Download GoogleService-Info.plist

3. **Add GoogleService-Info.plist**
   - Add the file to your Xcode project
   - Ensure it's included in your app target

### Configuration Options

```swift
let config = FirebaseConfiguration()

// Project settings
config.projectID = "your-project-id"
config.bundleID = "com.yourcompany.yourapp"

// Service settings
config.enableAnalytics = true
config.enableMessaging = true
config.enableDatabase = true
config.enableAuthentication = true
config.enableStorage = true
config.enableFunctions = true

// Performance settings
config.enablePerformanceMonitoring = true
config.enableCrashlytics = true

// Security settings
config.enableAppCheck = true
config.enableRemoteConfig = true
```

## Realtime Database

### Basic Database Operations

```swift
// Initialize database
let database = FirebaseRealtimeDatabase()

// Configure database
let dbConfig = DatabaseConfiguration()
dbConfig.databaseURL = "https://your-project.firebaseio.com"
dbConfig.enablePersistence = true
dbConfig.enableOfflineSupport = true

database.configure(dbConfig)

// Write data
let userData = [
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30
]

database.write("users/123", data: userData) { result in
    switch result {
    case .success:
        print("✅ Data written successfully")
    case .failure(let error):
        print("❌ Write failed: \(error)")
    }
}

// Read data
database.read("users/123") { result in
    switch result {
    case .success(let data):
        print("✅ User data: \(data)")
    case .failure(let error):
        print("❌ Read failed: \(error)")
    }
}

// Update data
database.update("users/123", data: ["age": 31]) { result in
    switch result {
    case .success:
        print("✅ Data updated successfully")
    case .failure(let error):
        print("❌ Update failed: \(error)")
    }
}

// Delete data
database.delete("users/123") { result in
    switch result {
    case .success:
        print("✅ Data deleted successfully")
    case .failure(let error):
        print("❌ Delete failed: \(error)")
    }
}
```

### Real-time Listeners

```swift
// Listen for real-time updates
database.listen("users/123") { result in
    switch result {
    case .success(let data):
        print("📨 Real-time update: \(data)")
    case .failure(let error):
        print("❌ Listener failed: \(error)")
    }
}

// Listen for multiple paths
database.listenMultiple([
    "users/123",
    "users/456",
    "messages/room1"
]) { updates in
    for (path, data) in updates {
        print("📨 Update for \(path): \(data)")
    }
}

// Stop listening
database.stopListening("users/123")
```

### Query Operations

```swift
// Query with conditions
let query = DatabaseQuery()
query.path = "users"
query.orderBy = "age"
query.limit = 10
query.startAt = 25
query.endAt = 35

database.query(query) { result in
    switch result {
    case .success(let users):
        print("✅ Query results: \(users)")
    case .failure(let error):
        print("❌ Query failed: \(error)")
    }
}

// Complex queries
let complexQuery = DatabaseQuery()
complexQuery.path = "messages"
complexQuery.orderBy = "timestamp"
complexQuery.limit = 50
complexQuery.whereField("roomId", isEqualTo: "room1")
complexQuery.whereField("timestamp", isGreaterThan: Date().timeIntervalSince1970 - 86400)

database.query(complexQuery) { result in
    switch result {
    case .success(let messages):
        print("✅ Messages: \(messages)")
    case .failure(let error):
        print("❌ Query failed: \(error)")
    }
}
```

### Transaction Operations

```swift
// Run transaction
database.runTransaction("users/123/balance") { currentData in
    guard let currentBalance = currentData["balance"] as? Double else {
        return nil
    }
    
    let newBalance = currentBalance + 100
    return ["balance": newBalance]
} completion: { result in
    switch result {
    case .success(let newData):
        print("✅ Transaction completed: \(newData)")
    case .failure(let error):
        print("❌ Transaction failed: \(error)")
    }
}
```

## Cloud Messaging

### Basic Setup

```swift
// Initialize Cloud Messaging
let messaging = FirebaseCloudMessaging()

// Configure messaging
let messagingConfig = MessagingConfiguration()
messagingConfig.enableNotifications = true
messagingConfig.enableDataMessages = true
messagingConfig.enableBackgroundMessages = true

messaging.configure(messagingConfig)

// Register for notifications
messaging.registerForNotifications { result in
    switch result {
    case .success(let token):
        print("✅ FCM token: \(token)")
    case .failure(let error):
        print("❌ Registration failed: \(error)")
    }
}
```

### Sending Notifications

```swift
// Send notification to specific user
let notification = FCMPushNotification(
    title: "New Message",
    body: "You have a new message from John",
    data: ["messageId": "123", "senderId": "456"]
)

messaging.sendNotification(notification, to: "user_token") { result in
    switch result {
    case .success:
        print("✅ Notification sent")
    case .failure(let error):
        print("❌ Notification failed: \(error)")
    }
}

// Send to topic
messaging.sendNotificationToTopic(notification, topic: "news") { result in
    switch result {
    case .success:
        print("✅ Topic notification sent")
    case .failure(let error):
        print("❌ Topic notification failed: \(error)")
    }
}

// Send to multiple users
let tokens = ["token1", "token2", "token3"]
messaging.sendNotificationToMultiple(notification, tokens: tokens) { result in
    switch result {
    case .success(let successCount):
        print("✅ Sent to \(successCount) users")
    case .failure(let error):
        print("❌ Multi-user notification failed: \(error)")
    }
}
```

### Handling Notifications

```swift
// Handle incoming notifications
messaging.onNotificationReceived { notification in
    print("📱 Received notification: \(notification)")
    
    // Handle notification data
    if let messageId = notification.data["messageId"] {
        print("Message ID: \(messageId)")
    }
}

// Handle notification tap
messaging.onNotificationTapped { notification in
    print("👆 Notification tapped: \(notification)")
    
    // Navigate to specific screen
    if let messageId = notification.data["messageId"] {
        // Navigate to message detail
    }
}

// Handle background messages
messaging.onBackgroundMessageReceived { notification in
    print("🔄 Background message: \(notification)")
    
    // Process background message
    return .newData
}
```

### Topic Management

```swift
// Subscribe to topic
messaging.subscribeToTopic("news") { result in
    switch result {
    case .success:
        print("✅ Subscribed to news topic")
    case .failure(let error):
        print("❌ Topic subscription failed: \(error)")
    }
}

// Unsubscribe from topic
messaging.unsubscribeFromTopic("news") { result in
    switch result {
    case .success:
        print("✅ Unsubscribed from news topic")
    case .failure(let error):
        print("❌ Topic unsubscription failed: \(error)")
    }
}

// Get subscribed topics
messaging.getSubscribedTopics { result in
    switch result {
    case .success(let topics):
        print("✅ Subscribed topics: \(topics)")
    case .failure(let error):
        print("❌ Failed to get topics: \(error)")
    }
}
```

## Authentication

### User Authentication

```swift
// Initialize authentication
let auth = FirebaseAuthentication()

// Configure authentication
let authConfig = AuthenticationConfiguration()
authConfig.enableEmailPassword = true
authConfig.enableGoogleSignIn = true
authConfig.enableAppleSignIn = true
authConfig.enableAnonymousAuth = true

auth.configure(authConfig)

// Sign up with email
auth.signUp(email: "user@example.com", password: "password123") { result in
    switch result {
    case .success(let user):
        print("✅ User created: \(user.uid)")
    case .failure(let error):
        print("❌ Sign up failed: \(error)")
    }
}

// Sign in with email
auth.signIn(email: "user@example.com", password: "password123") { result in
    switch result {
    case .success(let user):
        print("✅ Signed in: \(user.uid)")
    case .failure(let error):
        print("❌ Sign in failed: \(error)")
    }
}

// Sign out
auth.signOut { result in
    switch result {
    case .success:
        print("✅ Signed out successfully")
    case .failure(let error):
        print("❌ Sign out failed: \(error)")
    }
}
```

### Social Authentication

```swift
// Google Sign In
auth.signInWithGoogle { result in
    switch result {
    case .success(let user):
        print("✅ Google sign in: \(user.uid)")
    case .failure(let error):
        print("❌ Google sign in failed: \(error)")
    }
}

// Apple Sign In
auth.signInWithApple { result in
    switch result {
    case .success(let user):
        print("✅ Apple sign in: \(user.uid)")
    case .failure(let error):
        print("❌ Apple sign in failed: \(error)")
    }
}

// Anonymous authentication
auth.signInAnonymously { result in
    switch result {
    case .success(let user):
        print("✅ Anonymous sign in: \(user.uid)")
    case .failure(let error):
        print("❌ Anonymous sign in failed: \(error)")
    }
}
```

### User Management

```swift
// Get current user
if let currentUser = auth.currentUser {
    print("👤 Current user: \(currentUser.uid)")
    print("📧 Email: \(currentUser.email ?? "No email")")
    print("📱 Phone: \(currentUser.phoneNumber ?? "No phone")")
}

// Update user profile
let profileUpdates = UserProfileChangeRequest()
profileUpdates.displayName = "John Doe"
profileUpdates.photoURL = URL(string: "https://example.com/avatar.jpg")

auth.updateProfile(profileUpdates) { result in
    switch result {
    case .success:
        print("✅ Profile updated")
    case .failure(let error):
        print("❌ Profile update failed: \(error)")
    }
}

// Send email verification
auth.sendEmailVerification { result in
    switch result {
    case .success:
        print("✅ Verification email sent")
    case .failure(let error):
        print("❌ Verification email failed: \(error)")
    }
}

// Reset password
auth.sendPasswordReset(email: "user@example.com") { result in
    switch result {
    case .success:
        print("✅ Password reset email sent")
    case .failure(let error):
        print("❌ Password reset failed: \(error)")
    }
}
```

## Analytics

### Basic Analytics

```swift
// Initialize analytics
let analytics = FirebaseAnalytics()

// Configure analytics
let analyticsConfig = AnalyticsConfiguration()
analyticsConfig.enableAnalytics = true
analyticsConfig.enableCrashlytics = true
analyticsConfig.enablePerformanceMonitoring = true

analytics.configure(analyticsConfig)

// Log events
analytics.logEvent("user_login", parameters: [
    "method": "email",
    "user_id": "123"
])

// Log custom events
analytics.logCustomEvent("purchase_completed", parameters: [
    "item_id": "product_123",
    "price": 29.99,
    "currency": "USD"
])
```

### User Properties

```swift
// Set user properties
analytics.setUserProperty("premium", value: "true")
analytics.setUserProperty("subscription_type", value: "monthly")
analytics.setUserProperty("last_login", value: Date().timeIntervalSince1970)

// Set user ID
analytics.setUserID("user_123")
```

### Screen Tracking

```swift
// Track screen views
analytics.logScreenView("ChatScreen", parameters: [
    "room_id": "room_123",
    "user_count": 5
])

// Track app open
analytics.logAppOpen()
```

## Storage

### File Upload

```swift
// Initialize storage
let storage = FirebaseStorage()

// Configure storage
let storageConfig = StorageConfiguration()
storageConfig.bucket = "your-project.appspot.com"
storageConfig.enableCaching = true
storageConfig.maxCacheSize = 100 * 1024 * 1024 // 100MB

storage.configure(storageConfig)

// Upload file
let imageData = UIImage(named: "avatar")?.jpegData(compressionQuality: 0.8)
let fileRef = storage.reference().child("avatars/user_123.jpg")

storage.uploadData(imageData!, to: fileRef) { result in
    switch result {
    case .success(let metadata):
        print("✅ File uploaded: \(metadata.downloadURL?.absoluteString ?? "")")
    case .failure(let error):
        print("❌ Upload failed: \(error)")
    }
}
```

### File Download

```swift
// Download file
let downloadRef = storage.reference().child("avatars/user_123.jpg")

storage.downloadData(from: downloadRef) { result in
    switch result {
    case .success(let data):
        if let image = UIImage(data: data) {
            print("✅ Image downloaded")
        }
    case .failure(let error):
        print("❌ Download failed: \(error)")
    }
}
```

### File Management

```swift
// Delete file
let deleteRef = storage.reference().child("avatars/user_123.jpg")

storage.deleteFile(deleteRef) { result in
    switch result {
    case .success:
        print("✅ File deleted")
    case .failure(let error):
        print("❌ Delete failed: \(error)")
    }
}

// Get file metadata
storage.getMetadata(fileRef) { result in
    switch result {
    case .success(let metadata):
        print("📁 File size: \(metadata.size) bytes")
        print("📅 Created: \(metadata.timeCreated)")
    case .failure(let error):
        print("❌ Metadata failed: \(error)")
    }
}
```

## Functions

### Call Functions

```swift
// Initialize functions
let functions = FirebaseFunctions()

// Configure functions
let functionsConfig = FunctionsConfiguration()
functionsConfig.region = "us-central1"
functionsConfig.enableEmulator = false

functions.configure(functionsConfig)

// Call function
let data = ["message": "Hello from iOS!"]

functions.call("sendNotification", data: data) { result in
    switch result {
    case .success(let response):
        print("✅ Function response: \(response)")
    case .failure(let error):
        print("❌ Function failed: \(error)")
    }
}
```

## Performance

### Performance Monitoring

```swift
// Initialize performance
let performance = FirebasePerformance()

// Configure performance
let performanceConfig = PerformanceConfiguration()
performanceConfig.enableMonitoring = true
performanceConfig.enableNetworkMonitoring = true

performance.configure(performanceConfig)

// Start trace
let trace = performance.startTrace("user_action")
trace.setMetric("action_type", value: "button_click")

// End trace
trace.stop()
```

## Security

### Security Rules

```swift
// Database security rules
let dbRules = """
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "messages": {
      ".read": "auth != null",
      ".write": "auth != null"
    }
  }
}
"""

// Storage security rules
let storageRules = """
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /avatars/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
"""
```

## Best Practices

### 1. Database Design

- Use denormalized data for real-time apps
- Implement proper indexing
- Use security rules effectively
- Optimize for read/write patterns

### 2. Authentication

- Implement proper user management
- Use secure authentication methods
- Handle authentication state changes
- Implement proper error handling

### 3. Messaging

- Use topics for broadcast messages
- Implement proper token management
- Handle background messages
- Test on real devices

### 4. Storage

- Implement proper file organization
- Use appropriate file formats
- Implement caching strategies
- Handle upload/download progress

### 5. Security

- Always use security rules
- Validate all data
- Implement proper access control
- Use HTTPS for all communications

### 6. Performance

- Monitor app performance
- Optimize database queries
- Implement proper caching
- Use lazy loading

## Examples

### Complete Firebase Implementation

```swift
import RealTimeCommunication
import SwiftUI

class FirebaseManager: ObservableObject {
    private let firebaseManager = FirebaseManager()
    private let database = FirebaseRealtimeDatabase()
    private let messaging = FirebaseCloudMessaging()
    private let auth = FirebaseAuthentication()
    
    @Published var currentUser: FirebaseUser?
    @Published var messages: [ChatMessage] = []
    @Published var isAuthenticated = false
    
    init() {
        setupFirebase()
    }
    
    private func setupFirebase() {
        let config = FirebaseConfiguration()
        config.projectID = "your-project-id"
        config.enableAnalytics = true
        config.enableMessaging = true
        config.enableDatabase = true
        config.enableAuthentication = true
        
        firebaseManager.configure(config)
        
        // Setup authentication
        auth.onAuthStateChanged { [weak self] user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = (user != nil)
            }
        }
        
        // Setup messaging
        messaging.onNotificationReceived { notification in
            print("📱 Received notification: \(notification)")
        }
    }
    
    func signIn(email: String, password: String) {
        auth.signIn(email: email, password: password) { result in
            switch result {
            case .success(let user):
                print("✅ Signed in: \(user.uid)")
            case .failure(let error):
                print("❌ Sign in failed: \(error)")
            }
        }
    }
    
    func sendMessage(_ text: String, to roomId: String) {
        guard let user = currentUser else { return }
        
        let messageData = [
            "text": text,
            "senderId": user.uid,
            "senderName": user.displayName ?? "Anonymous",
            "timestamp": ServerValue.timestamp(),
            "roomId": roomId
        ]
        
        database.write("messages/\(UUID().uuidString)", data: messageData) { result in
            switch result {
            case .success:
                print("✅ Message sent")
            case .failure(let error):
                print("❌ Message failed: \(error)")
            }
        }
    }
    
    func listenForMessages(in roomId: String) {
        database.listen("messages") { result in
            switch result {
            case .success(let data):
                if let messages = data as? [String: Any] {
                    for (_, messageData) in messages {
                        if let message = messageData as? [String: Any],
                           let roomId = message["roomId"] as? String,
                           roomId == roomId {
                            // Handle new message
                            self.handleNewMessage(message)
                        }
                    }
                }
            case .failure(let error):
                print("❌ Message listener failed: \(error)")
            }
        }
    }
    
    private func handleNewMessage(_ messageData: [String: Any]) {
        guard let text = messageData["text"] as? String,
              let senderName = messageData["senderName"] as? String,
              let timestamp = messageData["timestamp"] as? TimeInterval else {
            return
        }
        
        let message = ChatMessage(
            text: text,
            sender: senderName,
            timestamp: Date(timeIntervalSince1970: timestamp)
        )
        
        DispatchQueue.main.async {
            self.messages.append(message)
        }
    }
}

struct FirebaseChatView: View {
    @StateObject private var firebaseManager = FirebaseManager()
    @State private var messageText = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isSigningIn = false
    
    var body: some View {
        if firebaseManager.isAuthenticated {
            // Chat interface
            VStack {
                // User info
                HStack {
                    Text("Welcome, \(firebaseManager.currentUser?.displayName ?? "User")")
                    Spacer()
                    Button("Sign Out") {
                        // Sign out logic
                    }
                }
                .padding()
                
                // Messages
                ScrollView {
                    LazyVStack {
                        ForEach(firebaseManager.messages) { message in
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
                    
                    Button("Send") {
                        firebaseManager.sendMessage(messageText, to: "general")
                        messageText = ""
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
            }
            .onAppear {
                firebaseManager.listenForMessages(in: "general")
            }
        } else {
            // Sign in interface
            VStack {
                Text("Sign In")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Sign In") {
                    isSigningIn = true
                    firebaseManager.signIn(email: email, password: password)
                }
                .disabled(email.isEmpty || password.isEmpty || isSigningIn)
                .padding()
            }
        }
    }
}
```

This comprehensive guide covers all aspects of Firebase integration in the iOS Real-Time Communication Framework. For more advanced features and examples, refer to the API documentation and other guides.
