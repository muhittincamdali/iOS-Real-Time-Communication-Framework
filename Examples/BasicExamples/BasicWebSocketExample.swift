import Foundation
import RealTimeCommunicationFramework

// MARK: - Basic WebSocket Example
// This example demonstrates a simple WebSocket connection with basic message handling

class BasicWebSocketExample {
    
    private let webSocket = WebSocketClient()
    private let serverURL = "wss://echo.websocket.org"
    
    func setupWebSocket() {
        // Configure WebSocket
        let config = WebSocketConfiguration()
        config.url = URL(string: serverURL)
        config.enableReconnection = true
        config.maxReconnectionAttempts = 3
        config.enableHeartbeat = true
        config.heartbeatInterval = 30
        config.enableLogging = true
        
        webSocket.configure(config)
        setupEventHandlers()
    }
    
    private func setupEventHandlers() {
        // Connection events
        webSocket.onConnect {
            print("✅ WebSocket connected to \(self.serverURL)")
        }
        
        webSocket.onDisconnect { reason in
            print("🔒 WebSocket disconnected: \(reason)")
        }
        
        webSocket.onError { error in
            print("❌ WebSocket error: \(error)")
        }
        
        // Message handling
        webSocket.onMessage { message in
            switch message.type {
            case .text:
                if let text = message.text {
                    print("📨 Received text message: \(text)")
                }
            case .binary:
                if let data = message.binary {
                    print("📨 Received binary data: \(data.count) bytes")
                }
            case .ping:
                print("🏓 Received ping")
            case .pong:
                print("🏓 Received pong")
            case .close:
                print("🔒 Connection closing")
            case .continuation:
                print("📨 Message continuation")
            }
        }
    }
    
    func connect() async {
        do {
            try await webSocket.connect()
        } catch {
            print("❌ Failed to connect: \(error)")
        }
    }
    
    func sendMessage(_ text: String) async {
        do {
            try await webSocket.send(text)
            print("✅ Message sent: \(text)")
        } catch {
            print("❌ Failed to send message: \(error)")
        }
    }
    
    func disconnect() {
        webSocket.disconnect()
    }
}

// MARK: - Usage Example
func runBasicWebSocketExample() async {
    let example = BasicWebSocketExample()
    example.setupWebSocket()
    
    // Connect to WebSocket
    await example.connect()
    
    // Send some messages
    await example.sendMessage("Hello, WebSocket!")
    await example.sendMessage("This is a test message")
    await example.sendMessage("Goodbye!")
    
    // Wait a bit for responses
    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
    
    // Disconnect
    example.disconnect()
}

// MARK: - Example Output
/*
✅ WebSocket connected to wss://echo.websocket.org
✅ Message sent: Hello, WebSocket!
📨 Received text message: Hello, WebSocket!
✅ Message sent: This is a test message
📨 Received text message: This is a test message
✅ Message sent: Goodbye!
📨 Received text message: Goodbye!
🔒 WebSocket disconnected: normal
*/ 