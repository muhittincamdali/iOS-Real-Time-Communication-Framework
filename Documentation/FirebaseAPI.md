# Firebase API

## Overview

The Firebase API provides comprehensive integration with Firebase services including Realtime Database, Cloud Messaging, Authentication, Analytics, and Cloud Functions. It offers a unified interface for all Firebase features with real-time synchronization and offline support.

## Core Classes

### FirebaseRealtimeDatabase

Firebase Realtime Database integration.

```swift
public class FirebaseRealtimeDatabase {
    // MARK: - Properties
    public var isConnected: Bool { get }
    public var databaseURL: URL { get }
    public var configuration: FirebaseConfiguration { get }
    
    // MARK: - Initialization
    public init()
    public init(databaseURL: URL)
    public init(configuration: FirebaseConfiguration)
    
    // MARK: - Configuration
    public func configure(_ configuration: FirebaseConfiguration)
    
    // MARK: - Data Operations
    public func read(_ path: String) async throws -> Any
    public func write(_ path: String, data: Any) async throws
    public func update(_ path: String, data: [String: Any]) async throws
    public func delete(_ path: String) async throws
    
    // MARK: - Real-time Listeners
    public func listen(_ path: String, callback: @escaping (FirebaseDataSnapshot) -> Void) -> FirebaseListener
    public func listenOnce(_ path: String, callback: @escaping (FirebaseDataSnapshot) -> Void)
    
    // MARK: - Query Operations
    public func query(_ path: String) -> FirebaseQuery
    public func orderByChild(_ child: String) -> FirebaseQuery
    public func orderByKey() -> FirebaseQuery
    public func orderByValue() -> FirebaseQuery
    public func limitToFirst(_ limit: UInt) -> FirebaseQuery
    public func limitToLast(_ limit: UInt) -> FirebaseQuery
    public func startAt(_ value: Any) -> FirebaseQuery
    public func endAt(_ value: Any) -> FirebaseQuery
    public func equalTo(_ value: Any) -> FirebaseQuery
    
    // MARK: - Transaction Operations
    public func runTransaction(_ path: String, updateBlock: @escaping (FirebaseMutableData) -> FirebaseTransactionResult) async throws
    
    // MARK: - Connection Events
    public func onConnected(_ handler: @escaping () -> Void)
    public func onDisconnected(_ handler: @escaping () -> Void)
    public func onError(_ handler: @escaping (FirebaseError) -> Void)
}
```

### FirebaseCloudMessaging

Firebase Cloud Messaging integration.

```swift
public class FirebaseCloudMessaging {
    // MARK: - Properties
    public var isConfigured: Bool { get }
    public var deviceToken: String? { get }
    public var configuration: FCMConfiguration { get }
    
    // MARK: - Initialization
    public init()
    public init(configuration: FCMConfiguration)
    
    // MARK: - Configuration
    public func configure(_ configuration: FCMConfiguration)
    public func registerForRemoteNotifications() async throws -> String
    
    // MARK: - Token Management
    public func refreshToken() async throws -> String
    public func deleteToken() async throws
    
    // MARK: - Topic Management
    public func subscribe(to topic: String) async throws
    public func unsubscribe(from topic: String) async throws
    public func subscribeToTopics(_ topics: [String]) async throws
    public func unsubscribeFromTopics(_ topics: [String]) async throws
    
    // MARK: - Message Handling
    public func sendMessage(_ message: FCMPushNotification, to token: String) async throws
    public func sendMessageToTopic(_ message: FCMPushNotification, topic: String) async throws
    public func sendMessageToMultipleTokens(_ message: FCMPushNotification, tokens: [String]) async throws
    
    // MARK: - Event Handling
    public func onMessageReceived(_ handler: @escaping (FCMPushNotification) -> Void)
    public func onTokenRefresh(_ handler: @escaping (String) -> Void)
    public func onRegistrationSuccess(_ handler: @escaping (String) -> Void)
    public func onRegistrationError(_ handler: @escaping (FirebaseError) -> Void)
}
```

### FirebaseAuthentication

Firebase Authentication integration.

```swift
public class FirebaseAuthentication {
    // MARK: - Properties
    public var currentUser: FirebaseUser? { get }
    public var isAuthenticated: Bool { get }
    public var configuration: FirebaseAuthConfiguration { get }
    
    // MARK: - Initialization
    public init()
    public init(configuration: FirebaseAuthConfiguration)
    
    // MARK: - Configuration
    public func configure(_ configuration: FirebaseAuthConfiguration)
    
    // MARK: - Authentication Methods
    public func signIn(with email: String, password: String) async throws -> FirebaseUser
    public func signUp(with email: String, password: String) async throws -> FirebaseUser
    public func signOut() async throws
    public func resetPassword(for email: String) async throws
    
    // MARK: - Social Authentication
    public func signInWithGoogle() async throws -> FirebaseUser
    public func signInWithApple() async throws -> FirebaseUser
    public func signInWithFacebook() async throws -> FirebaseUser
    public func signInWithTwitter() async throws -> FirebaseUser
    
    // MARK: - User Management
    public func updateProfile(displayName: String?, photoURL: URL?) async throws
    public func updateEmail(_ email: String) async throws
    public func updatePassword(_ password: String) async throws
    public func deleteAccount() async throws
    
    // MARK: - Event Handling
    public func onAuthStateChanged(_ handler: @escaping (FirebaseUser?) -> Void)
    public func onSignIn(_ handler: @escaping (FirebaseUser) -> Void)
    public func onSignOut(_ handler: @escaping () -> Void)
    public func onError(_ handler: @escaping (FirebaseError) -> Void)
}
```

### FirebaseConfiguration

Configuration for Firebase services.

```swift
public struct FirebaseConfiguration {
    // MARK: - Database Settings
    public var databaseURL: URL?
    public var enablePersistence: Bool
    public var enableOfflineSupport: Bool
    public var cacheSizeBytes: Int
    
    // MARK: - Messaging Settings
    public var enableNotifications: Bool
    public var enableDataMessages: Bool
    public var enableBackgroundMessages: Bool
    public var enableAnalytics: Bool
    
    // MARK: - Authentication Settings
    public var enableAnonymousAuth: Bool
    public var enableEmailAuth: Bool
    public var enableSocialAuth: Bool
    public var enablePhoneAuth: Bool
    
    // MARK: - Security Settings
    public var enableSecurityRules: Bool
    public var enableTokenValidation: Bool
    
    // MARK: - Logging Settings
    public var enableLogging: Bool
    public var logLevel: FirebaseLogLevel
}
```

### FirebaseDataSnapshot

Represents a snapshot of Firebase data.

```swift
public struct FirebaseDataSnapshot {
    // MARK: - Properties
    public let key: String?
    public let value: Any?
    public let exists: Bool
    public let childrenCount: UInt
    public let ref: FirebaseDatabaseReference
    
    // MARK: - Convenience Methods
    public var stringValue: String?
    public var numberValue: NSNumber?
    public var boolValue: Bool?
    public var dictionaryValue: [String: Any]?
    public var arrayValue: [Any]?
    
    // MARK: - Child Access
    public func child(_ path: String) -> FirebaseDataSnapshot
    public func hasChild(_ path: String) -> Bool
    public func children() -> [FirebaseDataSnapshot]
}
```

### FirebaseQuery

Query builder for Firebase Realtime Database.

```swift
public class FirebaseQuery {
    // MARK: - Query Methods
    public func orderByChild(_ child: String) -> FirebaseQuery
    public func orderByKey() -> FirebaseQuery
    public func orderByValue() -> FirebaseQuery
    public func limitToFirst(_ limit: UInt) -> FirebaseQuery
    public func limitToLast(_ limit: UInt) -> FirebaseQuery
    public func startAt(_ value: Any) -> FirebaseQuery
    public func endAt(_ value: Any) -> FirebaseQuery
    public func equalTo(_ value: Any) -> FirebaseQuery
    
    // MARK: - Execution
    public func observe(_ eventType: FirebaseEventType, callback: @escaping (FirebaseDataSnapshot) -> Void) -> FirebaseListener
    public func observeSingleEvent(_ eventType: FirebaseEventType, callback: @escaping (FirebaseDataSnapshot) -> Void)
}
```

### FCMPushNotification

Firebase Cloud Messaging notification.

```swift
public struct FCMPushNotification {
    // MARK: - Properties
    public let title: String?
    public let body: String?
    public let data: [String: Any]?
    public let badge: Int?
    public let sound: String?
    public let image: String?
    public let actionButtons: [FCMActionButton]?
    
    // MARK: - Initialization
    public init(title: String?, body: String?, data: [String: Any]? = nil)
    public init(title: String?, body: String?, data: [String: Any]?, badge: Int?, sound: String?)
    
    // MARK: - Builder Pattern
    public func withTitle(_ title: String) -> FCMPushNotification
    public func withBody(_ body: String) -> FCMPushNotification
    public func withData(_ data: [String: Any]) -> FCMPushNotification
    public func withBadge(_ badge: Int) -> FCMPushNotification
    public func withSound(_ sound: String) -> FCMPushNotification
    public func withImage(_ image: String) -> FCMPushNotification
    public func withActionButtons(_ buttons: [FCMActionButton]) -> FCMPushNotification
}
```

## Usage Examples

### Firebase Realtime Database

```swift
import RealTimeCommunicationFramework

// Create Firebase database instance
let firebaseDB = FirebaseRealtimeDatabase()

// Configure Firebase
let config = FirebaseConfiguration()
config.databaseURL = URL(string: "https://your-app.firebaseio.com")
config.enablePersistence = true
config.enableOfflineSupport = true
config.enableLogging = true

// Setup Firebase
firebaseDB.configure(config)

// Write data
let userData = [
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30,
    "lastSeen": ServerValue.timestamp()
]

try await firebaseDB.write("users/123", data: userData)

// Read data
let user = try await firebaseDB.read("users/123") as? [String: Any]
print("User: \(user)")

// Update data
let updates = [
    "users/123/lastSeen": ServerValue.timestamp(),
    "users/123/status": "online"
]

try await firebaseDB.update("", data: updates)
```

### Real-time Listeners

```swift
// Listen for real-time updates
let listener = firebaseDB.listen("users/123/messages") { snapshot in
    print("📨 New message received")
    if let messageData = snapshot.dictionaryValue {
        print("Message: \(messageData)")
    }
}

// Listen for user status changes
firebaseDB.listen("users/123/status") { snapshot in
    if let status = snapshot.stringValue {
        print("User status changed to: \(status)")
    }
}

// Remove listener when done
listener.remove()
```

### Firebase Cloud Messaging

```swift
// Create FCM instance
let fcm = FirebaseCloudMessaging()

// Configure FCM
let fcmConfig = FCMConfiguration()
fcmConfig.enableNotifications = true
fcmConfig.enableDataMessages = true
fcmConfig.enableBackgroundMessages = true

fcm.configure(fcmConfig)

// Register for notifications
let deviceToken = try await fcm.registerForRemoteNotifications()
print("Device token: \(deviceToken)")

// Subscribe to topics
try await fcm.subscribe(to: "news")
try await fcm.subscribe(to: "updates")

// Send notification
let notification = FCMPushNotification(
    title: "New Message",
    body: "You have a new message from John"
).withData(["messageId": "123"])
.withBadge(1)
.withSound("default")

try await fcm.sendMessage(notification, to: deviceToken)

// Handle incoming notifications
fcm.onMessageReceived { notification in
    print("📱 Received notification: \(notification.title ?? "")")
    print("Body: \(notification.body ?? "")")
    print("Data: \(notification.data ?? [:])")
}
```

### Firebase Authentication

```swift
// Create Firebase Auth instance
let auth = FirebaseAuthentication()

// Configure authentication
let authConfig = FirebaseAuthConfiguration()
authConfig.enableEmailAuth = true
authConfig.enableSocialAuth = true
authConfig.enableAnonymousAuth = true

auth.configure(authConfig)

// Sign in with email
let user = try await auth.signIn(with: "user@example.com", password: "password123")
print("Signed in user: \(user.uid)")

// Sign up new user
let newUser = try await auth.signUp(with: "newuser@example.com", password: "password123")
print("New user created: \(newUser.uid)")

// Update user profile
try await auth.updateProfile(displayName: "John Doe", photoURL: URL(string: "https://example.com/avatar.jpg"))

// Handle auth state changes
auth.onAuthStateChanged { user in
    if let user = user {
        print("✅ User signed in: \(user.uid)")
    } else {
        print("❌ User signed out")
    }
}
```

### Advanced Queries

```swift
// Create query
let query = firebaseDB.query("users")
    .orderByChild("age")
    .startAt(18)
    .endAt(65)
    .limitToFirst(10)

// Observe query results
let listener = query.observe(.value) { snapshot in
    print("Query results updated")
    for child in snapshot.children {
        if let userData = child.dictionaryValue {
            print("User: \(userData)")
        }
    }
}

// Search by specific value
let activeUsersQuery = firebaseDB.query("users")
    .orderByChild("status")
    .equalTo("active")

activeUsersQuery.observe(.value) { snapshot in
    print("Active users: \(snapshot.childrenCount)")
}
```

### Transactions

```swift
// Run transaction
try await firebaseDB.runTransaction("users/123/balance") { mutableData in
    let currentBalance = mutableData.numberValue?.intValue ?? 0
    let newBalance = currentBalance + 100
    
    mutableData.value = newBalance
    return .success
}

// Complex transaction
try await firebaseDB.runTransaction("transactions/456") { mutableData in
    let transactionData = mutableData.dictionaryValue ?? [:]
    let status = transactionData["status"] as? String ?? "pending"
    
    if status == "pending" {
        mutableData.child("status").value = "completed"
        mutableData.child("completedAt").value = ServerValue.timestamp()
        return .success
    } else {
        return .abort
    }
}
```

## Best Practices

1. **Use offline persistence** for better user experience
2. **Implement proper error handling** for all Firebase operations
3. **Use transactions** for data consistency
4. **Optimize queries** with proper indexing
5. **Handle authentication state** changes
6. **Implement proper security rules** in Firebase console
7. **Use topics** for targeted messaging
8. **Monitor connection status** for offline scenarios

## Performance Considerations

- Use offline persistence for critical data
- Implement proper query optimization
- Use transactions for complex data updates
- Monitor database usage and costs
- Implement proper caching strategies
- Use batch operations for multiple updates
- Monitor authentication token refresh
