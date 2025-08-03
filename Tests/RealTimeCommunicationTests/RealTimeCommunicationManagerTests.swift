import XCTest
import Foundation
@testable import RealTimeCommunication

@available(iOS 15.0, *)
final class RealTimeCommunicationManagerTests: XCTestCase {
    
    var manager: RealTimeCommunicationManager!
    var mockAnalytics: MockCommunicationAnalytics!
    
    override func setUp() {
        super.setUp()
        mockAnalytics = MockCommunicationAnalytics()
        manager = RealTimeCommunicationManager(analytics: mockAnalytics)
    }
    
    override func tearDown() {
        manager = nil
        mockAnalytics = nil
        super.tearDown()
    }
    
    func testInitializationWithAnalytics() {
        XCTAssertNotNil(manager)
        XCTAssertNotNil(mockAnalytics)
        XCTAssertEqual(manager.configuration.webSocketEnabled, true)
        XCTAssertEqual(manager.configuration.pushNotificationEnabled, true)
        XCTAssertEqual(manager.configuration.messageQueueEnabled, true)
    }
    
    func testWebSocketConnectionEstablishment() {
        let expectation = XCTestExpectation(description: "WebSocket connection")
        
        manager.establishWebSocketConnection(
            to: URL(string: "wss://echo.websocket.org")!
        ) { result in
            switch result {
            case .success(let connection):
                XCTAssertNotNil(connection)
                XCTAssertTrue(connection.isActive)
            case .failure(let error):
                XCTFail("WebSocket connection failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPushNotificationRegistration() {
        let expectation = XCTestExpectation(description: "Push notification registration")
        
        manager.registerForPushNotifications { result in
            switch result {
            case .success(let deviceToken):
                XCTAssertNotNil(deviceToken)
                XCTAssertFalse(deviceToken.isEmpty)
            case .failure(let error):
                XCTFail("Push notification registration failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testRealTimeMessageSending() {
        let expectation = XCTestExpectation(description: "Real-time message sending")
        
        let message = RealTimeMessage(
            title: "Test Message",
            body: "This is a test real-time message",
            data: "Test data".data(using: .utf8)!,
            type: .text,
            senderId: "test-sender"
        )
        
        manager.sendRealTimeMessage(message, to: ["recipient1", "recipient2"]) { result in
            switch result {
            case .success:
                XCTAssertTrue(true, "Real-time message sent successfully")
            case .failure(let error):
                XCTFail("Real-time message sending failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testConnectionStatistics() {
        let stats = manager.getConnectionStatistics()
        
        XCTAssertNotNil(stats)
        XCTAssertGreaterThanOrEqual(stats.totalConnections, 0)
        XCTAssertGreaterThanOrEqual(stats.activeConnections, 0)
        XCTAssertGreaterThanOrEqual(stats.webSocketConnections, 0)
    }
}

@available(iOS 15.0, *)
class MockCommunicationAnalytics: CommunicationAnalytics {
    var webSocketManagerSetupCalled = false
    var pushNotificationManagerSetupCalled = false
    var messageQueueSetupCalled = false
    var webSocketConnectionEstablishedCalled = false
    var webSocketConnectionFailedCalled = false
    var webSocketMessageSentCalled = false
    var webSocketMessageFailedCalled = false
    var webSocketConnectionClosedCalled = false
    var pushNotificationRegisteredCalled = false
    var pushNotificationRegistrationFailedCalled = false
    var pushNotificationSentCalled = false
    var pushNotificationFailedCalled = false
    var pushNotificationReceivedCalled = false
    var messageEnqueuedCalled = false
    var messageEnqueueFailedCalled = false
    var messagesProcessedCalled = false
    var messageProcessingFailedCalled = false
    var realTimeMessageSentCalled = false
    var realTimeMessageReceivedCalled = false
    var realTimeMessageDeliveredCalled = false
    var realTimeMessageFailedCalled = false
    var messageHandlerRegisteredCalled = false
    var messageNotificationHandledCalled = false
    var alertNotificationHandledCalled = false
    var updateNotificationHandledCalled = false
    var connectionHealthCheckedCalled = false
    
    var lastUrl: URL?
    var lastError: Error?
    var lastConnectionId: String?
    var lastDeviceToken: String?
    var lastNotificationId: String?
    var lastMessageId: String?
    var lastMessageType: String?
    var lastRecipientCount: Int?
    var lastErrorCount: Int?
    var lastProcessedCount: Int?
    var lastHealth: ConnectionHealth?
    
    func recordWebSocketManagerSetup() {
        webSocketManagerSetupCalled = true
    }
    
    func recordPushNotificationManagerSetup() {
        pushNotificationManagerSetupCalled = true
    }
    
    func recordMessageQueueSetup() {
        messageQueueSetupCalled = true
    }
    
    func recordWebSocketConnectionEstablished(url: URL) {
        webSocketConnectionEstablishedCalled = true
        lastUrl = url
    }
    
    func recordWebSocketConnectionFailed(error: Error) {
        webSocketConnectionFailedCalled = true
        lastError = error
    }
    
    func recordWebSocketMessageSent(connectionId: String) {
        webSocketMessageSentCalled = true
        lastConnectionId = connectionId
    }
    
    func recordWebSocketMessageFailed(error: Error) {
        webSocketMessageFailedCalled = true
        lastError = error
    }
    
    func recordWebSocketConnectionClosed(connectionId: String) {
        webSocketConnectionClosedCalled = true
        lastConnectionId = connectionId
    }
    
    func recordPushNotificationRegistered(deviceToken: String) {
        pushNotificationRegisteredCalled = true
        lastDeviceToken = deviceToken
    }
    
    func recordPushNotificationRegistrationFailed(error: Error) {
        pushNotificationRegistrationFailedCalled = true
        lastError = error
    }
    
    func recordPushNotificationSent(notificationId: String) {
        pushNotificationSentCalled = true
        lastNotificationId = notificationId
    }
    
    func recordPushNotificationFailed(error: Error) {
        pushNotificationFailedCalled = true
        lastError = error
    }
    
    func recordPushNotificationReceived(notificationId: String) {
        pushNotificationReceivedCalled = true
        lastNotificationId = notificationId
    }
    
    func recordMessageEnqueued(messageId: String, priority: MessagePriority) {
        messageEnqueuedCalled = true
        lastMessageId = messageId
    }
    
    func recordMessageEnqueueFailed(error: Error) {
        messageEnqueueFailedCalled = true
        lastError = error
    }
    
    func recordMessagesProcessed(count: Int) {
        messagesProcessedCalled = true
        lastProcessedCount = count
    }
    
    func recordMessageProcessingFailed(error: Error) {
        messageProcessingFailedCalled = true
        lastError = error
    }
    
    func recordRealTimeMessageSent(messageId: String, recipientCount: Int) {
        realTimeMessageSentCalled = true
        lastMessageId = messageId
        lastRecipientCount = recipientCount
    }
    
    func recordRealTimeMessageReceived(messageId: String) {
        realTimeMessageReceivedCalled = true
        lastMessageId = messageId
    }
    
    func recordRealTimeMessageDelivered(messageId: String) {
        realTimeMessageDeliveredCalled = true
        lastMessageId = messageId
    }
    
    func recordRealTimeMessageFailed(errorCount: Int) {
        realTimeMessageFailedCalled = true
        lastErrorCount = errorCount
    }
    
    func recordMessageHandlerRegistered(messageType: String) {
        messageHandlerRegisteredCalled = true
        lastMessageType = messageType
    }
    
    func recordMessageNotificationHandled(notificationId: String) {
        messageNotificationHandledCalled = true
        lastNotificationId = notificationId
    }
    
    func recordAlertNotificationHandled(notificationId: String) {
        alertNotificationHandledCalled = true
        lastNotificationId = notificationId
    }
    
    func recordUpdateNotificationHandled(notificationId: String) {
        updateNotificationHandledCalled = true
        lastNotificationId = notificationId
    }
    
    func recordConnectionHealthChecked(health: ConnectionHealth) {
        connectionHealthCheckedCalled = true
        lastHealth = health
    }
} 