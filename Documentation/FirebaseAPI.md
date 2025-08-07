# Firebase API

## Overview

The Firebase API provides comprehensive Firebase integration for iOS applications, including Realtime Database, Cloud Messaging, Authentication, and Analytics. This document covers all public interfaces, classes, and methods available in the Firebase module.

## Table of Contents

- [FirebaseManager](#firebasemanager)
- [FirebaseConfiguration](#firebaseconfiguration)
- [FirebaseRealtimeDatabase](#firebaserealtimedatabase)
- [FirebaseCloudMessaging](#firebasecloudmessaging)
- [FirebaseAuthentication](#firebaseauthentication)
- [FirebaseAnalytics](#firebaseanalytics)
- [FirebaseStorage](#firebasestorage)
- [FirebaseFunctions](#firebasefunctions)
- [FirebaseError](#firebaseerror)

## FirebaseManager

The main Firebase manager class that coordinates all Firebase services.

### Initialization

```swift
let firebaseManager = FirebaseManager()
```

### Configuration

```swift
func configure(_ configuration: FirebaseConfiguration)
```

Configures the Firebase manager with the specified configuration.

**Parameters:**
- `configuration`: The Firebase configuration object

**Example:**
```swift
let config = FirebaseConfiguration()
config.projectID = "your-project-id"
config.enableAnalytics = true
config.enableMessaging = true
config.enableDatabase = true

firebaseManager.configure(config)
```

### Service Management

```swift
func getRealtimeDatabase() -> FirebaseRealtimeDatabase
```

Gets the Realtime Database service.

**Returns:**
- The Realtime Database service instance

```swift
func getCloudMessaging() -> FirebaseCloudMessaging
```

Gets the Cloud Messaging service.

**Returns:**
- The Cloud Messaging service instance

```swift
func getAuthentication() -> FirebaseAuthentication
```

Gets the Authentication service.

**Returns:**
- The Authentication service instance

```swift
func getAnalytics() -> FirebaseAnalytics
```

Gets the Analytics service.

**Returns:**
- The Analytics service instance

```swift
func getStorage() -> FirebaseStorage
```

Gets the Storage service.

**Returns:**
- The Storage service instance

```swift
func getFunctions() -> FirebaseFunctions
```

Gets the Functions service.

**Returns:**
- The Functions service instance

## FirebaseConfiguration

Configuration class for Firebase services.

### Properties

```swift
var projectID: String
```

The Firebase project identifier.

```swift
var bundleID: String
```

The iOS app bundle identifier.

```swift
var enableAnalytics: Bool
```

Whether to enable Firebase Analytics.

```swift
var enableMessaging: Bool
```

Whether to enable Firebase Cloud Messaging.

```swift
var enableDatabase: Bool
```

Whether to enable Firebase Realtime Database.

```swift
var enableAuthentication: Bool
```

Whether to enable Firebase Authentication.

```swift
var enableStorage: Bool
```

Whether to enable Firebase Storage.

```swift
var enableFunctions: Bool
```

Whether to enable Firebase Functions.

```swift
var enablePerformanceMonitoring: Bool
```

Whether to enable Firebase Performance Monitoring.

```swift
var enableCrashlytics: Bool
```

Whether to enable Firebase Crashlytics.

```swift
var enableAppCheck: Bool
```

Whether to enable Firebase App Check.

```swift
var enableRemoteConfig: Bool
```

Whether to enable Firebase Remote Config.

### Example

```swift
let config = FirebaseConfiguration()
config.projectID = "your-project-id"
config.bundleID = "com.yourcompany.yourapp"
config.enableAnalytics = true
config.enableMessaging = true
config.enableDatabase = true
config.enableAuthentication = true
config.enableStorage = true
config.enableFunctions = true
config.enablePerformanceMonitoring = true
config.enableCrashlytics = true
config.enableAppCheck = true
config.enableRemoteConfig = true
```

## FirebaseRealtimeDatabase

Manages Firebase Realtime Database operations.

### Initialization

```swift
let database = FirebaseRealtimeDatabase()
```

### Configuration

```swift
func configure(_ configuration: DatabaseConfiguration)
```

Configures the Realtime Database with the specified configuration.

**Parameters:**
- `configuration`: The database configuration object

**Example:**
```swift
let dbConfig = DatabaseConfiguration()
dbConfig.databaseURL = "https://your-project.firebaseio.com"
dbConfig.enablePersistence = true
dbConfig.enableOfflineSupport = true

database.configure(dbConfig)
```

### Data Operations

```swift
func write(_ path: String, data: [String: Any], completion: @escaping (Result<Void, FirebaseError>) -> Void)
```

Writes data to the specified path.

**Parameters:**
- `path`: The database path
- `data`: The data to write
- `completion`: Completion handler called with the write result

**Example:**
```swift
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
```

```swift
func read(_ path: String, completion: @escaping (Result<Any, FirebaseError>) -> Void)
```

Reads data from the specified path.

**Parameters:**
- `path`: The database path
- `completion`: Completion handler called with the read result

**Example:**
```swift
database.read("users/123") { result in
    switch result {
    case .success(let data):
        print("✅ Data read: \(data)")
    case .failure(let error):
        print("❌ Read failed: \(error)")
    }
}
```

```swift
func update(_ path: String, data: [String: Any], completion: @escaping (Result<Void, FirebaseError>) -> Void)
```

Updates data at the specified path.

**Parameters:**
- `path`: The database path
- `data`: The data to update
- `completion`: Completion handler called with the update result

**Example:**
```swift
database.update("users/123", data: ["age": 31]) { result in
    switch result {
    case .success:
        print("✅ Data updated successfully")
    case .failure(let error):
        print("❌ Update failed: \(error)")
    }
}
```

```swift
func delete(_ path: String, completion: @escaping (Result<Void, FirebaseError>) -> Void)
```

Deletes data at the specified path.

**Parameters:**
- `path`: The database path
- `completion`: Completion handler called with the delete result

**Example:**
```swift
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
func listen(_ path: String, completion: @escaping (Result<Any, FirebaseError>) -> Void)
```

Sets up a real-time listener for the specified path.

**Parameters:**
- `path`: The database path
- `completion`: Completion handler called when data changes

**Example:**
```swift
database.listen("users/123/messages") { result in
    switch result {
    case .success(let data):
        print("📨 Real-time update: \(data)")
    case .failure(let error):
        print("❌ Listener failed: \(error)")
    }
}
```

```swift
func stopListening(_ path: String)
```

Stops listening to the specified path.

**Parameters:**
- `path`: The database path

### Query Operations

```swift
func query(_ query: DatabaseQuery, completion: @escaping (Result<[Any], FirebaseError>) -> Void)
```

Performs a query on the database.

**Parameters:**
- `query`: The database query
- `completion`: Completion handler called with the query results

**Example:**
```swift
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
```

## FirebaseCloudMessaging

Manages Firebase Cloud Messaging operations.

### Initialization

```swift
let messaging = FirebaseCloudMessaging()
```

### Configuration

```swift
func configure(_ configuration: FCMConfiguration)
```

Configures the Cloud Messaging service.

**Parameters:**
- `configuration`: The FCM configuration object

**Example:**
```swift
let fcmConfig = FCMConfiguration()
fcmConfig.enableNotifications = true
fcmConfig.enableDataMessages = true
fcmConfig.enableBackgroundMessages = true

messaging.configure(fcmConfig)
```

### Token Management

```swift
func registerForNotifications(completion: @escaping (Result<String, FirebaseError>) -> Void)
```

Registers for push notifications and gets the FCM token.

**Parameters:**
- `completion`: Completion handler called with the registration result

**Example:**
```swift
messaging.registerForNotifications { result in
    switch result {
    case .success(let token):
        print("✅ FCM token: \(token)")
    case .failure(let error):
        print("❌ Registration failed: \(error)")
    }
}
```

```swift
func onTokenRefresh(_ handler: @escaping (String) -> Void)
```

Sets up a handler for token refresh events.

**Parameters:**
- `handler`: Closure called when the token is refreshed

**Example:**
```swift
messaging.onTokenRefresh { newToken in
    print("🔄 FCM token refreshed: \(newToken)")
}
```

### Sending Notifications

```swift
func sendNotification(_ notification: FCMPushNotification, to token: String, completion: @escaping (Result<Void, FirebaseError>) -> Void)
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

messaging.sendNotification(notification, to: "device_token") { result in
    switch result {
    case .success:
        print("✅ Notification sent")
    case .failure(let error):
        print("❌ Notification failed: \(error)")
    }
}
```

```swift
func sendNotificationToTopic(_ notification: FCMPushNotification, topic: String, completion: @escaping (Result<Void, FirebaseError>) -> Void)
```

Sends a push notification to a topic.

**Parameters:**
- `notification`: The push notification
- `topic`: The topic name
- `completion`: Completion handler called with the send result

**Example:**
```swift
messaging.sendNotificationToTopic(notification, topic: "news") { result in
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
func subscribeToTopic(_ topic: String, completion: @escaping (Result<Void, FirebaseError>) -> Void)
```

Subscribes to a topic.

**Parameters:**
- `topic`: The topic name
- `completion`: Completion handler called with the subscription result

**Example:**
```swift
messaging.subscribeToTopic("news") { result in
    switch result {
    case .success:
        print("✅ Subscribed to news topic")
    case .failure(let error):
        print("❌ Topic subscription failed: \(error)")
    }
}
```

```swift
func unsubscribeFromTopic(_ topic: String, completion: @escaping (Result<Void, FirebaseError>) -> Void)
```

Unsubscribes from a topic.

**Parameters:**
- `topic`: The topic name
- `completion`: Completion handler called with the unsubscription result

**Example:**
```swift
messaging.unsubscribeFromTopic("news") { result in
    switch result {
    case .success:
        print("✅ Unsubscribed from news topic")
    case .failure(let error):
        print("❌ Topic unsubscription failed: \(error)")
    }
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
messaging.onNotificationReceived { notification in
    print("📱 Received notification: \(notification)")
    
    // Handle notification data
    if let messageId = notification.userInfo["messageId"] {
        print("Message ID: \(messageId)")
    }
}
```

## FirebaseAuthentication

Manages Firebase Authentication operations.

### Initialization

```swift
let auth = FirebaseAuthentication()
```

### Configuration

```swift
func configure(_ configuration: AuthConfiguration)
```

Configures the Authentication service.

**Parameters:**
- `configuration`: The authentication configuration object

**Example:**
```swift
let authConfig = AuthConfiguration()
authConfig.enableEmailPassword = true
authConfig.enableGoogleSignIn = true
authConfig.enableAppleSignIn = true
authConfig.enableAnonymousAuth = true

auth.configure(authConfig)
```

### User Authentication

```swift
func signUp(email: String, password: String, completion: @escaping (Result<FirebaseUser, FirebaseError>) -> Void)
```

Signs up a new user with email and password.

**Parameters:**
- `email`: The user's email address
- `password`: The user's password
- `completion`: Completion handler called with the sign-up result

**Example:**
```swift
auth.signUp(email: "user@example.com", password: "password123") { result in
    switch result {
    case .success(let user):
        print("✅ User created: \(user.uid)")
    case .failure(let error):
        print("❌ Sign up failed: \(error)")
    }
}
```

```swift
func signIn(email: String, password: String, completion: @escaping (Result<FirebaseUser, FirebaseError>) -> Void)
```

Signs in a user with email and password.

**Parameters:**
- `email`: The user's email address
- `password`: The user's password
- `completion`: Completion handler called with the sign-in result

**Example:**
```swift
auth.signIn(email: "user@example.com", password: "password123") { result in
    switch result {
    case .success(let user):
        print("✅ Signed in: \(user.uid)")
    case .failure(let error):
        print("❌ Sign in failed: \(error)")
    }
}
```

```swift
func signOut(completion: @escaping (Result<Void, FirebaseError>) -> Void)
```

Signs out the current user.

**Parameters:**
- `completion`: Completion handler called with the sign-out result

**Example:**
```swift
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
func signInWithGoogle(completion: @escaping (Result<FirebaseUser, FirebaseError>) -> Void)
```

Signs in a user with Google.

**Parameters:**
- `completion`: Completion handler called with the sign-in result

**Example:**
```swift
auth.signInWithGoogle { result in
    switch result {
    case .success(let user):
        print("✅ Google sign in: \(user.uid)")
    case .failure(let error):
        print("❌ Google sign in failed: \(error)")
    }
}
```

```swift
func signInWithApple(completion: @escaping (Result<FirebaseUser, FirebaseError>) -> Void)
```

Signs in a user with Apple.

**Parameters:**
- `completion`: Completion handler called with the sign-in result

**Example:**
```swift
auth.signInWithApple { result in
    switch result {
    case .success(let user):
        print("✅ Apple sign in: \(user.uid)")
    case .failure(let error):
        print("❌ Apple sign in failed: \(error)")
    }
}
```

### User Management

```swift
var currentUser: FirebaseUser?
```

The currently signed-in user.

```swift
func updateProfile(_ profile: UserProfileChangeRequest, completion: @escaping (Result<Void, FirebaseError>) -> Void)
```

Updates the current user's profile.

**Parameters:**
- `profile`: The profile change request
- `completion`: Completion handler called with the update result

**Example:**
```swift
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
```

## FirebaseAnalytics

Manages Firebase Analytics operations.

### Initialization

```swift
let analytics = FirebaseAnalytics()
```

### Configuration

```swift
func configure(_ configuration: AnalyticsConfiguration)
```

Configures the Analytics service.

**Parameters:**
- `configuration`: The analytics configuration object

**Example:**
```swift
let analyticsConfig = AnalyticsConfiguration()
analyticsConfig.enableAnalytics = true
analyticsConfig.enableCrashlytics = true
analyticsConfig.enablePerformanceMonitoring = true

analytics.configure(analyticsConfig)
```

### Event Logging

```swift
func logEvent(_ name: String, parameters: [String: Any]?)
```

Logs a custom event.

**Parameters:**
- `name`: The event name
- `parameters`: Optional event parameters

**Example:**
```swift
analytics.logEvent("user_login", parameters: [
    "method": "email",
    "user_id": "123"
])
```

```swift
func logCustomEvent(_ name: String, parameters: [String: Any]?)
```

Logs a custom event with custom parameters.

**Parameters:**
- `name`: The event name
- `parameters`: Optional event parameters

**Example:**
```swift
analytics.logCustomEvent("purchase_completed", parameters: [
    "item_id": "product_123",
    "price": 29.99,
    "currency": "USD"
])
```

### User Properties

```swift
func setUserProperty(_ value: String?, forName name: String)
```

Sets a user property.

**Parameters:**
- `value`: The property value
- `name`: The property name

**Example:**
```swift
analytics.setUserProperty("premium", forName: "subscription_type")
analytics.setUserProperty("true", forName: "is_premium")
```

```swift
func setUserID(_ userID: String)
```

Sets the user ID.

**Parameters:**
- `userID`: The user identifier

**Example:**
```swift
analytics.setUserID("user_123")
```

### Screen Tracking

```swift
func logScreenView(_ screenName: String, parameters: [String: Any]?)
```

Logs a screen view.

**Parameters:**
- `screenName`: The screen name
- `parameters`: Optional screen parameters

**Example:**
```swift
analytics.logScreenView("ChatScreen", parameters: [
    "room_id": "room_123",
    "user_count": 5
])
```

## FirebaseStorage

Manages Firebase Storage operations.

### Initialization

```swift
let storage = FirebaseStorage()
```

### Configuration

```swift
func configure(_ configuration: StorageConfiguration)
```

Configures the Storage service.

**Parameters:**
- `configuration`: The storage configuration object

**Example:**
```swift
let storageConfig = StorageConfiguration()
storageConfig.bucket = "your-project.appspot.com"
storageConfig.enableCaching = true
storageConfig.maxCacheSize = 100 * 1024 * 1024 // 100MB

storage.configure(storageConfig)
```

### File Operations

```swift
func uploadData(_ data: Data, to path: String, completion: @escaping (Result<StorageMetadata, FirebaseError>) -> Void)
```

Uploads data to Firebase Storage.

**Parameters:**
- `data`: The data to upload
- `path`: The storage path
- `completion`: Completion handler called with the upload result

**Example:**
```swift
let imageData = UIImage(named: "avatar")?.jpegData(compressionQuality: 0.8)
storage.uploadData(imageData!, to: "avatars/user_123.jpg") { result in
    switch result {
    case .success(let metadata):
        print("✅ File uploaded: \(metadata.downloadURL?.absoluteString ?? "")")
    case .failure(let error):
        print("❌ Upload failed: \(error)")
    }
}
```

```swift
func downloadData(from path: String, completion: @escaping (Result<Data, FirebaseError>) -> Void)
```

Downloads data from Firebase Storage.

**Parameters:**
- `path`: The storage path
- `completion`: Completion handler called with the download result

**Example:**
```swift
storage.downloadData(from: "avatars/user_123.jpg") { result in
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

```swift
func deleteFile(at path: String, completion: @escaping (Result<Void, FirebaseError>) -> Void)
```

Deletes a file from Firebase Storage.

**Parameters:**
- `path`: The storage path
- `completion`: Completion handler called with the delete result

**Example:**
```swift
storage.deleteFile(at: "avatars/user_123.jpg") { result in
    switch result {
    case .success:
        print("✅ File deleted")
    case .failure(let error):
        print("❌ Delete failed: \(error)")
    }
}
```

## FirebaseFunctions

Manages Firebase Cloud Functions operations.

### Initialization

```swift
let functions = FirebaseFunctions()
```

### Configuration

```swift
func configure(_ configuration: FunctionsConfiguration)
```

Configures the Functions service.

**Parameters:**
- `configuration`: The functions configuration object

**Example:**
```swift
let functionsConfig = FunctionsConfiguration()
functionsConfig.region = "us-central1"
functionsConfig.enableEmulator = false

functions.configure(functionsConfig)
```

### Function Calls

```swift
func call(_ functionName: String, data: [String: Any], completion: @escaping (Result<Any, FirebaseError>) -> Void)
```

Calls a Firebase Cloud Function.

**Parameters:**
- `functionName`: The function name
- `data`: The function data
- `completion`: Completion handler called with the function result

**Example:**
```swift
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

## FirebaseError

Represents Firebase errors.

### Error Types

```swift
enum FirebaseError: Error {
    case configurationFailed(String)
    case authenticationFailed(String)
    case databaseError(String)
    case storageError(String)
    case messagingError(String)
    case functionsError(String)
    case networkError(Error)
    case permissionDenied(String)
    case notFound(String)
    case alreadyExists(String)
    case invalidArgument(String)
    case unavailable(String)
    case deadlineExceeded(String)
    case resourceExhausted(String)
    case internalError(String)
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
firebaseManager.onError { error in
    switch error {
    case .configurationFailed(let reason):
        print("Configuration failed: \(reason)")
    case .authenticationFailed(let reason):
        print("Authentication failed: \(reason)")
    case .databaseError(let message):
        print("Database error: \(message)")
    case .storageError(let message):
        print("Storage error: \(message)")
    case .messagingError(let message):
        print("Messaging error: \(message)")
    case .functionsError(let message):
        print("Functions error: \(message)")
    case .networkError(let underlyingError):
        print("Network error: \(underlyingError)")
    case .permissionDenied(let resource):
        print("Permission denied: \(resource)")
    case .notFound(let resource):
        print("Not found: \(resource)")
    case .alreadyExists(let resource):
        print("Already exists: \(resource)")
    case .invalidArgument(let argument):
        print("Invalid argument: \(argument)")
    case .unavailable(let service):
        print("Service unavailable: \(service)")
    case .deadlineExceeded(let operation):
        print("Deadline exceeded: \(operation)")
    case .resourceExhausted(let resource):
        print("Resource exhausted: \(resource)")
    case .internalError(let message):
        print("Internal error: \(message)")
    }
}
```

## Complete Example

```swift
import RealTimeCommunication

class FirebaseManager: ObservableObject {
    private let firebaseManager = FirebaseManager()
    private let database = FirebaseRealtimeDatabase()
    private let messaging = FirebaseCloudMessaging()
    private let auth = FirebaseAuthentication()
    private let analytics = FirebaseAnalytics()
    
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
    
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        analytics.logEvent(name, parameters: parameters)
    }
}

struct FirebaseChatView: View {
    @StateObject private var firebaseManager = FirebaseManager()
    @State private var messageText = ""
    @State private var email = ""
    @State private var password = ""
    
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
                    firebaseManager.signIn(email: email, password: password)
                }
                .disabled(email.isEmpty || password.isEmpty)
                .padding()
            }
        }
    }
}
```

This comprehensive API documentation covers all aspects of the Firebase module in the iOS Real-Time Communication Framework. For more examples and advanced usage, refer to the Firebase Guide and other documentation.
