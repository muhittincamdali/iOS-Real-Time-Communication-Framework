import Foundation
import RealTimeCommunicationFramework

// MARK: - Firebase Realtime Database Example
// This example demonstrates Firebase Realtime Database integration

class FirebaseRealtimeExample {
    
    private let firebaseDB = FirebaseRealtimeDatabase()
    private var listeners: [FirebaseListener] = []
    
    func setupFirebase() {
        let config = FirebaseConfiguration()
        config.databaseURL = URL(string: "https://your-app.firebaseio.com")
        config.enablePersistence = true
        config.enableOfflineSupport = true
        config.cacheSizeBytes = 100 * 1024 * 1024 // 100MB
        config.enableLogging = true
        
        firebaseDB.configure(config)
        setupEventHandlers()
    }
    
    private func setupEventHandlers() {
        firebaseDB.onConnected {
            print("✅ Connected to Firebase Realtime Database")
        }
        
        firebaseDB.onDisconnected {
            print("🔒 Disconnected from Firebase")
        }
        
        firebaseDB.onError { error in
            print("❌ Firebase error: \(error)")
        }
    }
    
    func writeUserData(_ user: User) async {
        let userData: [String: Any] = [
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "status": user.status.rawValue,
            "lastSeen": ServerValue.timestamp(),
            "createdAt": ServerValue.timestamp()
        ]
        
        do {
            try await firebaseDB.write("users/\(user.id)", data: userData)
            print("✅ User data written: \(user.name)")
        } catch {
            print("❌ Failed to write user data: \(error)")
        }
    }
    
    func writeMessage(_ message: ChatMessage) async {
        let messageData: [String: Any] = [
            "id": message.id,
            "text": message.text,
            "sender": [
                "id": message.sender.id,
                "name": message.sender.name
            ],
            "roomId": message.roomId,
            "timestamp": ServerValue.timestamp(),
            "type": message.type.rawValue
        ]
        
        do {
            try await firebaseDB.write("messages/\(message.id)", data: messageData)
            print("✅ Message written: \(message.text)")
        } catch {
            print("❌ Failed to write message: \(error)")
        }
    }
    
    func listenToUserStatus(_ userId: String) {
        let listener = firebaseDB.listen("users/\(userId)/status") { snapshot in
            if let status = snapshot.stringValue {
                print("👤 User \(userId) status changed to: \(status)")
            }
        }
        listeners.append(listener)
    }
    
    func listenToRoomMessages(_ roomId: String) {
        let listener = firebaseDB.listen("messages") { snapshot in
            if let messages = snapshot.dictionaryValue {
                print("📨 New messages in room \(roomId): \(messages.count) messages")
            }
        }
        listeners.append(listener)
    }
    
    func queryActiveUsers() async {
        let query = firebaseDB.query("users")
            .orderByChild("status")
            .equalTo("online")
            .limitToFirst(10)
        
        let listener = query.observe(.value) { snapshot in
            print("👥 Active users: \(snapshot.childrenCount)")
            for child in snapshot.children {
                if let userData = child.dictionaryValue {
                    let name = userData["name"] as? String ?? "Unknown"
                    print("  - \(name)")
                }
            }
        }
        listeners.append(listener)
    }
    
    func runTransaction() async {
        do {
            try await firebaseDB.runTransaction("users/123/balance") { mutableData in
                let currentBalance = mutableData.numberValue?.intValue ?? 0
                let newBalance = currentBalance + 100
                
                mutableData.value = newBalance
                return .success
            }
            print("✅ Transaction completed successfully")
        } catch {
            print("❌ Transaction failed: \(error)")
        }
    }
    
    func updateUserStatus(_ userId: String, status: UserStatus) async {
        let updates: [String: Any] = [
            "users/\(userId)/status": status.rawValue,
            "users/\(userId)/lastSeen": ServerValue.timestamp()
        ]
        
        do {
            try await firebaseDB.update("", data: updates)
            print("✅ User status updated: \(status.rawValue)")
        } catch {
            print("❌ Failed to update user status: \(error)")
        }
    }
    
    func deleteMessage(_ messageId: String) async {
        do {
            try await firebaseDB.delete("messages/\(messageId)")
            print("✅ Message deleted: \(messageId)")
        } catch {
            print("❌ Failed to delete message: \(error)")
        }
    }
    
    func cleanup() {
        // Remove all listeners
        for listener in listeners {
            listener.remove()
        }
        listeners.removeAll()
        print("🧹 Cleanup completed")
    }
}

// MARK: - Data Models
struct User {
    let id: String
    let name: String
    let email: String
    let status: UserStatus
    
    enum UserStatus: String {
        case online = "online"
        case offline = "offline"
        case away = "away"
        case busy = "busy"
    }
}

struct ChatMessage {
    let id: String
    let text: String
    let sender: User
    let roomId: String
    let type: MessageType
    
    enum MessageType: String {
        case text = "text"
        case image = "image"
        case file = "file"
        case system = "system"
    }
}

// MARK: - Usage Example
func runFirebaseRealtimeExample() async {
    let firebase = FirebaseRealtimeExample()
    
    // Setup Firebase
    firebase.setupFirebase()
    
    // Create and write user data
    let user = User(
        id: "user123",
        name: "John Doe",
        email: "john@example.com",
        status: .online
    )
    
    await firebase.writeUserData(user)
    
    // Create and write message
    let message = ChatMessage(
        id: "msg123",
        text: "Hello, Firebase!",
        sender: user,
        roomId: "general",
        type: .text
    )
    
    await firebase.writeMessage(message)
    
    // Listen to user status changes
    firebase.listenToUserStatus("user123")
    
    // Listen to room messages
    firebase.listenToRoomMessages("general")
    
    // Query active users
    await firebase.queryActiveUsers()
    
    // Run transaction
    await firebase.runTransaction()
    
    // Update user status
    await firebase.updateUserStatus("user123", status: .away)
    
    // Wait for real-time updates
    try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
    
    // Cleanup
    firebase.cleanup()
}

// MARK: - Example Output
/*
✅ Connected to Firebase Realtime Database
✅ User data written: John Doe
✅ Message written: Hello, Firebase!
👤 User user123 status changed to: online
📨 New messages in room general: 1 messages
👥 Active users: 3
  - John Doe
  - Alice Smith
  - Bob Johnson
✅ Transaction completed successfully
✅ User status updated: away
👤 User user123 status changed to: away
🧹 Cleanup completed
*/ 