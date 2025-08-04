import Foundation
import RealTimeCommunicationFramework

// MARK: - WebSocket Chat Example
// This example demonstrates a WebSocket-based chat implementation

class WebSocketChatExample {
    
    private let webSocket = WebSocketClient()
    private let serverURL = "wss://chat.example.com/ws"
    
    private var currentUser: String = ""
    private var currentRoom: String = ""
    private var isConnected = false
    
    func setupChat() {
        let config = WebSocketConfiguration()
        config.url = URL(string: serverURL)
        config.enableReconnection = true
        config.maxReconnectionAttempts = 5
        config.enableHeartbeat = true
        config.heartbeatInterval = 30
        config.enableLogging = true
        config.enableMessageQueuing = true
        config.queueTimeout = 60
        
        webSocket.configure(config)
        setupEventHandlers()
    }
    
    private func setupEventHandlers() {
        webSocket.onConnect {
            self.isConnected = true
            print("✅ Connected to WebSocket chat server")
        }
        
        webSocket.onDisconnect { reason in
            self.isConnected = false
            print("🔒 Disconnected from chat server: \(reason)")
        }
        
        webSocket.onError { error in
            print("❌ WebSocket error: \(error)")
        }
        
        webSocket.onMessage { message in
            self.handleChatMessage(message)
        }
    }
    
    func connect() async {
        do {
            try await webSocket.connect()
        } catch {
            print("❌ Failed to connect: \(error)")
        }
    }
    
    func authenticate(_ username: String) async {
        currentUser = username
        
        let authMessage = ChatMessage(
            type: .authentication,
            data: ["username": username],
            sender: username
        )
        
        do {
            try await sendChatMessage(authMessage)
            print("✅ Authenticated as: \(username)")
        } catch {
            print("❌ Authentication failed: \(error)")
        }
    }
    
    func joinRoom(_ roomName: String) async {
        currentRoom = roomName
        
        let joinMessage = ChatMessage(
            type: .joinRoom,
            data: ["room": roomName],
            sender: currentUser
        )
        
        do {
            try await sendChatMessage(joinMessage)
            print("✅ Joined room: \(roomName)")
        } catch {
            print("❌ Failed to join room: \(error)")
        }
    }
    
    func sendTextMessage(_ text: String) async {
        let message = ChatMessage(
            type: .text,
            data: ["text": text, "room": currentRoom],
            sender: currentUser
        )
        
        do {
            try await sendChatMessage(message)
            print("✅ Message sent: \(text)")
        } catch {
            print("❌ Failed to send message: \(error)")
        }
    }
    
    func sendTypingIndicator(_ isTyping: Bool) async {
        let message = ChatMessage(
            type: isTyping ? .typingStart : .typingStop,
            data: ["room": currentRoom],
            sender: currentUser
        )
        
        do {
            try await sendChatMessage(message)
        } catch {
            print("❌ Failed to send typing indicator: \(error)")
        }
    }
    
    private func sendChatMessage(_ message: ChatMessage) async throws {
        let jsonData = try JSONEncoder().encode(message)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
        
        try await webSocket.send(jsonString)
    }
    
    private func handleChatMessage(_ message: WebSocketMessage) {
        guard let text = message.text else { return }
        
        do {
            let chatMessage = try JSONDecoder().decode(ChatMessage.self, from: text.data(using: .utf8) ?? Data())
            processChatMessage(chatMessage)
        } catch {
            print("❌ Failed to parse chat message: \(error)")
        }
    }
    
    private func processChatMessage(_ message: ChatMessage) {
        switch message.type {
        case .text:
            if let text = message.data["text"] as? String {
                displayMessage(message.sender, text: text)
            }
        case .userJoined:
            if let username = message.data["username"] as? String {
                print("👤 \(username) joined the room")
            }
        case .userLeft:
            if let username = message.data["username"] as? String {
                print("👋 \(username) left the room")
            }
        case .typingStart:
            if let username = message.data["username"] as? String {
                print("⌨️ \(username) started typing...")
            }
        case .typingStop:
            if let username = message.data["username"] as? String {
                print("⏹️ \(username) stopped typing")
            }
        case .system:
            if let text = message.data["text"] as? String {
                print("ℹ️ System: \(text)")
            }
        case .authentication:
            if let success = message.data["success"] as? Bool {
                if success {
                    print("✅ Authentication successful")
                } else {
                    print("❌ Authentication failed")
                }
            }
        case .joinRoom:
            if let room = message.data["room"] as? String {
                print("✅ Successfully joined room: \(room)")
            }
        }
    }
    
    private func displayMessage(_ sender: String, text: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
        print("💬 [\(timestamp)] \(sender): \(text)")
    }
    
    func disconnect() {
        webSocket.disconnect()
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Codable {
    let type: MessageType
    let data: [String: Any]
    let sender: String
    let timestamp: Date
    
    enum MessageType: String, Codable {
        case text = "text"
        case userJoined = "user_joined"
        case userLeft = "user_left"
        case typingStart = "typing_start"
        case typingStop = "typing_stop"
        case system = "system"
        case authentication = "auth"
        case joinRoom = "join_room"
    }
    
    init(type: MessageType, data: [String: Any], sender: String) {
        self.type = type
        self.data = data
        self.sender = sender
        self.timestamp = Date()
    }
    
    // Custom coding for dictionary data
    enum CodingKeys: String, CodingKey {
        case type, sender, timestamp
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(MessageType.self, forKey: .type)
        sender = try container.decode(String.self, forKey: .sender)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        
        // Decode data as JSON
        let dataString = try container.decode(String.self, forKey: .data)
        if let data = dataString.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            self.data = json
        } else {
            self.data = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(sender, forKey: .sender)
        try container.encode(timestamp, forKey: .timestamp)
        
        // Encode data as JSON string
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
        try container.encode(jsonString, forKey: .data)
    }
}

// MARK: - Usage Example
func runWebSocketChatExample() async {
    let chat = WebSocketChatExample()
    
    // Setup chat
    chat.setupChat()
    
    // Connect to server
    await chat.connect()
    
    // Authenticate user
    await chat.authenticate("JohnDoe")
    
    // Join a room
    await chat.joinRoom("general")
    
    // Send messages
    await chat.sendTextMessage("Hello, everyone!")
    await chat.sendTypingIndicator(true)
    
    // Simulate typing
    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
    
    await chat.sendTypingIndicator(false)
    await chat.sendTextMessage("How is everyone doing today?")
    
    // Wait for responses
    try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
    
    // Disconnect
    chat.disconnect()
}

// MARK: - Example Output
/*
✅ Connected to WebSocket chat server
✅ Authenticated as: JohnDoe
✅ Successfully joined room: general
✅ Message sent: Hello, everyone!
💬 [2:30 PM] Alice: Hi John! Welcome to the chat!
💬 [2:31 PM] Bob: Hello John! How are you?
⌨️ Alice started typing...
⏹️ Alice stopped typing
💬 [2:32 PM] Alice: Great to see you here!
✅ Message sent: How is everyone doing today?
💬 [2:33 PM] Charlie: Doing great! Thanks for asking!
👤 David joined the room
💬 [2:34 PM] David: Hi everyone!
🔒 Disconnected from chat server: normal
*/ 