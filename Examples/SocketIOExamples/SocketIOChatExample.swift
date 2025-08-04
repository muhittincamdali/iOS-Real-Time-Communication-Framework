import Foundation
import RealTimeCommunicationFramework

// MARK: - Socket.IO Chat Example
// This example demonstrates a Socket.IO-based chat implementation

class SocketIOChatExample {
    
    private let socketIO = SocketIOClient(serverURL: URL(string: "https://chat.example.com")!)
    private var currentUser: String = ""
    private var currentRoom: String = ""
    
    func setupChat() {
        let config = SocketIOConfiguration()
        config.serverURL = URL(string: "https://chat.example.com")!
        config.namespace = "/chat"
        config.enableReconnection = true
        config.reconnectionAttempts = 5
        config.reconnectionDelay = 1000
        config.enableLogging = true
        
        socketIO.configure(config)
        setupEventHandlers()
    }
    
    private func setupEventHandlers() {
        socketIO.onConnect {
            print("✅ Connected to Socket.IO chat server")
        }
        
        socketIO.onDisconnect { reason in
            print("🔒 Disconnected from chat server: \(reason)")
        }
        
        socketIO.onError { error in
            print("❌ Socket.IO error: \(error)")
        }
        
        // Chat events
        socketIO.on("message") { event in
            self.handleMessageEvent(event)
        }
        
        socketIO.on("user_joined") { event in
            self.handleUserJoinedEvent(event)
        }
        
        socketIO.on("user_left") { event in
            self.handleUserLeftEvent(event)
        }
        
        socketIO.on("typing_started") { event in
            self.handleTypingStartedEvent(event)
        }
        
        socketIO.on("typing_stopped") { event in
            self.handleTypingStoppedEvent(event)
        }
        
        socketIO.on("room_joined") { event in
            self.handleRoomJoinedEvent(event)
        }
    }
    
    func connect() async {
        do {
            try await socketIO.connect()
        } catch {
            print("❌ Failed to connect: \(error)")
        }
    }
    
    func authenticate(_ username: String) async {
        currentUser = username
        
        do {
            try await socketIO.emit("authenticate", data: [
                "username": username,
                "timestamp": Date().timeIntervalSince1970
            ])
            print("✅ Authentication request sent for: \(username)")
        } catch {
            print("❌ Authentication failed: \(error)")
        }
    }
    
    func joinRoom(_ roomName: String) async {
        currentRoom = roomName
        
        do {
            try await socketIO.emit("join_room", data: [
                "room": roomName,
                "user": currentUser
            ])
            print("✅ Join room request sent for: \(roomName)")
        } catch {
            print("❌ Failed to join room: \(error)")
        }
    }
    
    func sendMessage(_ text: String) async {
        do {
            try await socketIO.emit("message", data: [
                "text": text,
                "room": currentRoom,
                "sender": currentUser,
                "timestamp": Date().timeIntervalSince1970
            ])
            print("✅ Message sent: \(text)")
        } catch {
            print("❌ Failed to send message: \(error)")
        }
    }
    
    func sendTypingIndicator(_ isTyping: Bool) async {
        do {
            let event = isTyping ? "typing_started" : "typing_stopped"
            try await socketIO.emit(event, data: [
                "room": currentRoom,
                "user": currentUser
            ])
        } catch {
            print("❌ Failed to send typing indicator: \(error)")
        }
    }
    
    private func handleMessageEvent(_ event: SocketIOEvent) {
        if let data = event.dictionaryData,
           let text = data["text"] as? String,
           let sender = data["sender"] as? String {
            
            let timestamp = data["timestamp"] as? TimeInterval ?? Date().timeIntervalSince1970
            let date = Date(timeIntervalSince1970: timestamp)
            let timeString = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
            
            print("💬 [\(timeString)] \(sender): \(text)")
        }
    }
    
    private func handleUserJoinedEvent(_ event: SocketIOEvent) {
        if let data = event.dictionaryData,
           let username = data["username"] as? String {
            print("👤 \(username) joined the room")
        }
    }
    
    private func handleUserLeftEvent(_ event: SocketIOEvent) {
        if let data = event.dictionaryData,
           let username = data["username"] as? String {
            print("👋 \(username) left the room")
        }
    }
    
    private func handleTypingStartedEvent(_ event: SocketIOEvent) {
        if let data = event.dictionaryData,
           let username = data["username"] as? String {
            print("⌨️ \(username) started typing...")
        }
    }
    
    private func handleTypingStoppedEvent(_ event: SocketIOEvent) {
        if let data = event.dictionaryData,
           let username = data["username"] as? String {
            print("⏹️ \(username) stopped typing")
        }
    }
    
    private func handleRoomJoinedEvent(_ event: SocketIOEvent) {
        if let data = event.dictionaryData,
           let room = data["room"] as? String {
            print("✅ Successfully joined room: \(room)")
        }
    }
    
    func disconnect() {
        socketIO.disconnect()
    }
}

// MARK: - Usage Example
func runSocketIOChatExample() async {
    let chat = SocketIOChatExample()
    
    // Setup chat
    chat.setupChat()
    
    // Connect to server
    await chat.connect()
    
    // Authenticate user
    await chat.authenticate("JohnDoe")
    
    // Join a room
    await chat.joinRoom("general")
    
    // Send messages
    await chat.sendMessage("Hello, everyone!")
    await chat.sendTypingIndicator(true)
    
    // Simulate typing
    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
    
    await chat.sendTypingIndicator(false)
    await chat.sendMessage("How is everyone doing today?")
    
    // Wait for responses
    try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
    
    // Disconnect
    chat.disconnect()
}

// MARK: - Example Output
/*
✅ Connected to Socket.IO chat server
✅ Authentication request sent for: JohnDoe
✅ Join room request sent for: general
✅ Successfully joined room: general
👤 Alice joined the room
💬 [2:30 PM] Alice: Hi John! Welcome to the chat!
✅ Message sent: Hello, everyone!
💬 [2:31 PM] Bob: Hello John! How are you?
⌨️ Alice started typing...
⏹️ Alice stopped typing
💬 [2:32 PM] Alice: Great to see you here!
✅ Message sent: How is everyone doing today?
💬 [2:33 PM] Charlie: Doing great! Thanks for asking!
👋 David left the room
🔒 Disconnected from chat server: clientDisconnect
*/ 