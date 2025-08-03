import SwiftUI
import RealTimeCommunication

@available(iOS 15.0, *)
struct ChatAppExample: View {
    @StateObject private var chatManager = ChatManager()
    @State private var messageText = ""
    @State private var isConnected = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Connection Status
                ConnectionStatusView(isConnected: isConnected)
                
                // Chat Messages
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(chatManager.messages) { message in
                            MessageBubbleView(message: message)
                        }
                    }
                    .padding()
                }
                
                // Message Input
                MessageInputView(
                    text: $messageText,
                    onSend: {
                        chatManager.sendMessage(messageText)
                        messageText = ""
                    }
                )
            }
            .navigationTitle("Real-Time Chat")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                chatManager.connect()
            }
            .onReceive(chatManager.$isConnected) { connected in
                isConnected = connected
            }
        }
    }
}

@available(iOS 15.0, *)
class ChatManager: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isConnected = false
    
    private let communicationManager = RealTimeCommunicationManager()
    private var connectionId: String?
    
    init() {
        setupMessageHandlers()
    }
    
    func connect() {
        // Connect to WebSocket server
        communicationManager.establishWebSocketConnection(
            to: URL(string: "wss://chat.example.com/ws")!
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let connection):
                    self?.connectionId = connection.id
                    self?.isConnected = true
                    self?.sendSystemMessage("Connected to chat server")
                case .failure(let error):
                    self?.sendSystemMessage("Connection failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func disconnect() {
        if let connectionId = connectionId {
            communicationManager.closeWebSocketConnection(connectionId: connectionId)
        }
        isConnected = false
        sendSystemMessage("Disconnected from chat server")
    }
    
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = ChatMessage(
            id: UUID().uuidString,
            text: text,
            sender: "User",
            timestamp: Date(),
            type: .user
        )
        
        // Add to local messages
        messages.append(message)
        
        // Send via WebSocket
        if let connectionId = connectionId {
            let wsMessage = WebSocketMessage(
                data: text.data(using: .utf8)!,
                type: .text
            )
            
            communicationManager.sendWebSocketMessage(
                connectionId: connectionId,
                message: wsMessage
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Message sent successfully")
                    case .failure(let error):
                        self.sendSystemMessage("Failed to send message: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func setupMessageHandlers() {
        let handler = ChatMessageHandler { [weak self] message in
            DispatchQueue.main.async {
                let chatMessage = ChatMessage(
                    id: message.id,
                    text: message.body,
                    sender: message.senderId,
                    timestamp: message.timestamp,
                    type: .received
                )
                self?.messages.append(chatMessage)
            }
        }
        
        communicationManager.registerMessageHandler(handler, for: "chat")
    }
    
    private func sendSystemMessage(_ text: String) {
        let systemMessage = ChatMessage(
            id: UUID().uuidString,
            text: text,
            sender: "System",
            timestamp: Date(),
            type: .system
        )
        messages.append(systemMessage)
    }
}

@available(iOS 15.0, *)
struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let sender: String
    let timestamp: Date
    let type: MessageType
    
    enum MessageType {
        case user
        case received
        case system
    }
}

@available(iOS 15.0, *)
struct ConnectionStatusView: View {
    let isConnected: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Text(isConnected ? "Connected" : "Disconnected")
                .font(.caption)
                .foregroundColor(isConnected ? .green : .red)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
    }
}

@available(iOS 15.0, *)
struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.type == .user {
                Spacer()
            }
            
            VStack(alignment: message.type == .user ? .trailing : .leading, spacing: 4) {
                if message.type != .system {
                    Text(message.sender)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(message.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(bubbleColor)
                    .foregroundColor(bubbleTextColor)
                    .cornerRadius(16)
                
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if message.type != .user {
                Spacer()
            }
        }
    }
    
    private var bubbleColor: Color {
        switch message.type {
        case .user:
            return .blue
        case .received:
            return .gray.opacity(0.2)
        case .system:
            return .orange.opacity(0.2)
        }
    }
    
    private var bubbleTextColor: Color {
        switch message.type {
        case .user:
            return .white
        case .received, .system:
            return .primary
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

@available(iOS 15.0, *)
struct MessageInputView: View {
    @Binding var text: String
    let onSend: () -> Void
    
    var body: some View {
        HStack {
            TextField("Type a message...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSend()
                }
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.blue)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }
}

@available(iOS 15.0, *)
class ChatMessageHandler: MessageHandler {
    private let onMessageReceived: (RealTimeMessage) -> Void
    
    init(onMessageReceived: @escaping (RealTimeMessage) -> Void) {
        self.onMessageReceived = onMessageReceived
    }
    
    func handle(_ message: RealTimeMessage) {
        onMessageReceived(message)
    }
}

@available(iOS 15.0, *)
struct ChatAppExample_Previews: PreviewProvider {
    static var previews: some View {
        ChatAppExample()
    }
} 