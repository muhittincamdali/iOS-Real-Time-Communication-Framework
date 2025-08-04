import Foundation
import RealTimeCommunicationFramework

// MARK: - Real-Time Chat Example
// This example demonstrates a complete real-time chat implementation with multiple protocols

class RealTimeChatExample {
    
    private let rtcManager = RealTimeCommunicationManager()
    private let chatManager = RealTimeChat()
    private let webSocketClient = WebSocketClient()
    private let socketIOClient = SocketIOClient(serverURL: URL(string: "https://chat.example.com")!)
    
    private var currentUser: ChatUser?
    private var activeRooms: [String] = []
    
    // MARK: - Chat User Model
    struct ChatUser {
        let id: String
        let name: String
        let avatar: String?
        let status: UserStatus
        
        enum UserStatus: String {
            case online = "online"
            case offline = "offline"
            case away = "away"
            case busy = "busy"
        }
    }
    
    // MARK: - Chat Message Model
    struct ChatMessage {
        let id: String
        let text: String
        let sender: ChatUser
        let timestamp: Date
        let roomId: String
        let messageType: MessageType
        
        enum MessageType: String {
            case text = "text"
            case image = "image"
            case file = "file"
            case system = "system"
        }
    }
    
    func setupChat() {
        setupRealTimeCommunication()
        setupWebSocket()
        setupSocketIO()
        setupEventHandlers()
    }
    
    private func setupRealTimeCommunication() {
        let config = RealTimeCommunicationConfiguration()
        config.enableWebSocket = true
        config.enableSocketIO = true
        config.enableFirebase = true
        config.enablePushNotifications = true
        config.connectionTimeout = 30
        config.maxReconnectionAttempts = 5
        config.enableHeartbeat = true
        config.enableEncryption = true
        config.enableLogging = true
        
        rtcManager.configure(config)
    }
    
    private func setupWebSocket() {
        let wsConfig = WebSocketConfiguration()
        wsConfig.url = URL(string: "wss://chat.example.com/ws")
        wsConfig.enableReconnection = true
        wsConfig.maxReconnectionAttempts = 5
        wsConfig.enableHeartbeat = true
        wsConfig.heartbeatInterval = 30
        
        webSocketClient.configure(wsConfig)
    }
    
    private func setupSocketIO() {
        let socketIOConfig = SocketIOConfiguration()
        socketIOConfig.serverURL = URL(string: "https://chat.example.com")!
        socketIOConfig.namespace = "/chat"
        socketIOConfig.enableReconnection = true
        socketIOConfig.reconnectionAttempts = 5
        socketIOConfig.enableLogging = true
        
        socketIOClient.configure(socketIOConfig)
    }
    
    private func setupEventHandlers() {
        // Real-time communication events
        rtcManager.onConnectionStatusChanged { status in
            switch status {
            case .connected:
                print("✅ All communication protocols connected")
            case .connecting:
                print("🔄 Connecting to communication protocols...")
            case .disconnected:
                print("❌ Disconnected from communication protocols")
            case .reconnecting:
                print("🔄 Reconnecting to communication protocols...")
            case .failed(let error):
                print("❌ Communication failed: \(error)")
            }
        }
        
        // WebSocket events
        webSocketClient.onMessage { message in
            self.handleWebSocketMessage(message)
        }
        
        // Socket.IO events
        socketIOClient.on("message") { event in
            self.handleSocketIOMessage(event)
        }
        
        socketIOClient.on("user_joined") { event in
            self.handleUserJoined(event)
        }
        
        socketIOClient.on("user_left") { event in
            self.handleUserLeft(event)
        }
        
        socketIOClient.on("typing_started") { event in
            self.handleTypingStarted(event)
        }
        
        socketIOClient.on("typing_stopped") { event in
            self.handleTypingStopped(event)
        }
    }
    
    func startChat() async {
        do {
            // Start real-time communication
            try await rtcManager.connect()
            
            // Connect WebSocket
            try await webSocketClient.connect()
            
            // Connect Socket.IO
            try await socketIOClient.connect()
            
            print("✅ Chat system started successfully")
        } catch {
            print("❌ Failed to start chat: \(error)")
        }
    }
    
    func joinRoom(_ roomId: String) async {
        do {
            // Join Socket.IO room
            try await socketIOClient.joinRoom(roomId)
            
            // Join WebSocket room
            let joinMessage = WebSocketMessage(text: "JOIN_ROOM:\(roomId)")
            try await webSocketClient.send(joinMessage)
            
            activeRooms.append(roomId)
            print("✅ Joined room: \(roomId)")
        } catch {
            print("❌ Failed to join room: \(error)")
        }
    }
    
    func sendMessage(_ text: String, to roomId: String) async {
        guard let user = currentUser else {
            print("❌ User not authenticated")
            return
        }
        
        let message = ChatMessage(
            id: UUID().uuidString,
            text: text,
            sender: user,
            timestamp: Date(),
            roomId: roomId,
            messageType: .text
        )
        
        do {
            // Send via Socket.IO
            try await socketIOClient.emit("message", data: [
                "id": message.id,
                "text": message.text,
                "sender": [
                    "id": message.sender.id,
                    "name": message.sender.name
                ],
                "timestamp": message.timestamp.timeIntervalSince1970,
                "roomId": message.roomId,
                "type": message.messageType.rawValue
            ])
            
            // Send via WebSocket
            let wsMessage = WebSocketMessage(text: "MESSAGE:\(text)")
            try await webSocketClient.send(wsMessage)
            
            print("✅ Message sent to room \(roomId): \(text)")
        } catch {
            print("❌ Failed to send message: \(error)")
        }
    }
    
    func sendTypingIndicator(_ isTyping: Bool, in roomId: String) async {
        do {
            let event = isTyping ? "typing_started" : "typing_stopped"
            try await socketIOClient.emit(event, data: [
                "roomId": roomId,
                "userId": currentUser?.id ?? "",
                "userName": currentUser?.name ?? ""
            ])
        } catch {
            print("❌ Failed to send typing indicator: \(error)")
        }
    }
    
    private func handleWebSocketMessage(_ message: WebSocketMessage) {
        switch message.type {
        case .text:
            if let text = message.text {
                print("📨 WebSocket message: \(text)")
                // Parse and handle message
                parseWebSocketMessage(text)
            }
        case .binary:
            if let data = message.binary {
                print("📨 WebSocket binary data: \(data.count) bytes")
                // Handle binary data (images, files, etc.)
            }
        default:
            break
        }
    }
    
    private func handleSocketIOMessage(_ event: SocketIOEvent) {
        if let messageData = event.dictionaryData {
            print("📨 Socket.IO message: \(messageData)")
            
            // Parse message data
            if let text = messageData["text"] as? String,
               let senderData = messageData["sender"] as? [String: Any],
               let senderId = senderData["id"] as? String,
               let senderName = senderData["name"] as? String {
                
                let sender = ChatUser(
                    id: senderId,
                    name: senderName,
                    avatar: senderData["avatar"] as? String,
                    status: .online
                )
                
                let message = ChatMessage(
                    id: messageData["id"] as? String ?? UUID().uuidString,
                    text: text,
                    sender: sender,
                    timestamp: Date(timeIntervalSince1970: messageData["timestamp"] as? TimeInterval ?? 0),
                    roomId: messageData["roomId"] as? String ?? "",
                    messageType: ChatMessage.MessageType(rawValue: messageData["type"] as? String ?? "text") ?? .text
                )
                
                displayMessage(message)
            }
        }
    }
    
    private func handleUserJoined(_ event: SocketIOEvent) {
        if let userData = event.dictionaryData {
            print("👤 User joined: \(userData)")
        }
    }
    
    private func handleUserLeft(_ event: SocketIOEvent) {
        if let userData = event.dictionaryData {
            print("👋 User left: \(userData)")
        }
    }
    
    private func handleTypingStarted(_ event: SocketIOEvent) {
        if let userData = event.dictionaryData {
            let userName = userData["userName"] as? String ?? "Unknown"
            print("⌨️ \(userName) started typing...")
        }
    }
    
    private func handleTypingStopped(_ event: SocketIOEvent) {
        if let userData = event.dictionaryData {
            let userName = userData["userName"] as? String ?? "Unknown"
            print("⏹️ \(userName) stopped typing")
        }
    }
    
    private func parseWebSocketMessage(_ text: String) {
        // Parse WebSocket message format
        if text.hasPrefix("MESSAGE:") {
            let messageText = String(text.dropFirst(8))
            print("📨 Parsed WebSocket message: \(messageText)")
        } else if text.hasPrefix("JOIN_ROOM:") {
            let roomId = String(text.dropFirst(10))
            print("📨 User joined room: \(roomId)")
        }
    }
    
    private func displayMessage(_ message: ChatMessage) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        print("💬 [\(formatter.string(from: message.timestamp))] \(message.sender.name): \(message.text)")
    }
    
    func authenticateUser(_ user: ChatUser) {
        currentUser = user
        print("✅ User authenticated: \(user.name)")
    }
    
    func stopChat() {
        rtcManager.disconnect()
        webSocketClient.disconnect()
        socketIOClient.disconnect()
        print("🔒 Chat stopped")
    }
}

// MARK: - Usage Example
func runRealTimeChatExample() async {
    let chat = RealTimeChatExample()
    
    // Setup chat system
    chat.setupChat()
    
    // Authenticate user
    let user = RealTimeChatExample.ChatUser(
        id: "user123",
        name: "John Doe",
        avatar: "https://example.com/avatar.jpg",
        status: .online
    )
    chat.authenticateUser(user)
    
    // Start chat
    await chat.startChat()
    
    // Join a chat room
    await chat.joinRoom("general")
    
    // Send some messages
    await chat.sendMessage("Hello, everyone!", to: "general")
    await chat.sendTypingIndicator(true, in: "general")
    
    // Simulate typing
    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    
    await chat.sendTypingIndicator(false, in: "general")
    await chat.sendMessage("How is everyone doing?", to: "general")
    
    // Wait for responses
    try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
    
    // Stop chat
    chat.stopChat()
}

// MARK: - Example Output
/*
✅ User authenticated: John Doe
🔄 Connecting to communication protocols...
✅ All communication protocols connected
✅ WebSocket connected to wss://chat.example.com/ws
✅ Socket.IO connected
✅ Chat system started successfully
✅ Joined room: general
✅ Message sent to room general: Hello, everyone!
⌨️ John Doe started typing...
⏹️ John Doe stopped typing
✅ Message sent to room general: How is everyone doing?
💬 [2:30 PM] Alice: Hi John! How are you?
💬 [2:31 PM] Bob: Welcome to the chat!
💬 [2:32 PM] Charlie: Great to see you here!
🔒 Chat stopped
*/ 