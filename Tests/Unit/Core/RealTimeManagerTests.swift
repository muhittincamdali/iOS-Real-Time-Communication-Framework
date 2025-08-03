import XCTest
@testable import RealTimeCommunication

final class RealTimeManagerTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: RealTimeManager!
    private var mockWebSocketManager: MockWebSocketManager!
    private var mockPushNotificationManager: MockPushNotificationManager!
    private var mockMessageQueueManager: MockMessageQueueManager!
    private var mockAnalyticsManager: MockAnalyticsManager!
    private var mockConnectionManager: MockConnectionManager!
    private var testConfiguration: RealTimeConfig!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        
        testConfiguration = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key",
            enablePushNotifications: true,
            enableAnalytics: true
        )
        
        mockWebSocketManager = MockWebSocketManager()
        mockPushNotificationManager = MockPushNotificationManager()
        mockMessageQueueManager = MockMessageQueueManager()
        mockAnalyticsManager = MockAnalyticsManager()
        mockConnectionManager = MockConnectionManager()
        
        sut = RealTimeManager(configuration: testConfiguration)
    }
    
    override func tearDown() {
        sut = nil
        mockWebSocketManager = nil
        mockPushNotificationManager = nil
        mockMessageQueueManager = nil
        mockAnalyticsManager = nil
        mockConnectionManager = nil
        testConfiguration = nil
        
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func test_init_withConfiguration_createsManagerWithCorrectConfiguration() {
        // Given
        let config = RealTimeConfig(
            serverURL: "wss://test.com",
            apiKey: "test-key",
            enablePushNotifications: false,
            enableAnalytics: false
        )
        
        // When
        let manager = RealTimeManager(configuration: config)
        
        // Then
        XCTAssertNotNil(manager)
        XCTAssertEqual(manager.connectionStatus, .disconnected)
    }
    
    func test_sharedInstance_returnsSingleton() {
        // When
        let instance1 = RealTimeManager.shared
        let instance2 = RealTimeManager.shared
        
        // Then
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - Connection Tests
    
    func test_connect_success_returnsConnectionResult() async throws {
        // Given
        mockWebSocketManager.shouldConnect = true
        mockPushNotificationManager.shouldRegister = true
        
        // When
        let result = try await sut.connect()
        
        // Then
        XCTAssertEqual(result.status, .connected)
        XCTAssertEqual(result.serverURL, testConfiguration.serverURL)
        XCTAssertNotNil(result.sessionID)
        XCTAssertNotNil(result.connectionTime)
    }
    
    func test_connect_webSocketFailure_throwsConnectionError() async {
        // Given
        mockWebSocketManager.shouldConnect = false
        mockWebSocketManager.error = ConnectionError.networkUnavailable
        
        // When & Then
        do {
            _ = try await sut.connect()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? ConnectionError, .networkUnavailable)
        }
    }
    
    func test_connect_pushNotificationFailure_throwsConnectionError() async {
        // Given
        mockWebSocketManager.shouldConnect = true
        mockPushNotificationManager.shouldRegister = false
        mockPushNotificationManager.error = ConnectionError.authenticationFailed
        
        // When & Then
        do {
            _ = try await sut.connect()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? ConnectionError, .authenticationFailed)
        }
    }
    
    func test_disconnect_success_returnsDisconnectionResult() async {
        // Given
        mockWebSocketManager.shouldDisconnect = true
        mockPushNotificationManager.shouldUnregister = true
        
        // When
        let result = await sut.disconnect()
        
        // Then
        XCTAssertEqual(result.status, .disconnected)
        XCTAssertNotNil(result.sessionDuration)
        XCTAssertNil(result.error)
    }
    
    func test_disconnect_webSocketFailure_returnsErrorResult() async {
        // Given
        mockWebSocketManager.shouldDisconnect = false
        mockWebSocketManager.error = ConnectionError.disconnectionFailed(NSError(domain: "test", code: 1))
        
        // When
        let result = await sut.disconnect()
        
        // Then
        XCTAssertEqual(result.status, .error)
        XCTAssertNotNil(result.error)
    }
    
    // MARK: - Message Tests
    
    func test_send_message_success_callsWebSocketManager() {
        // Given
        let message = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: "Hello, World!".data(using: .utf8)!,
            timestamp: Date()
        )
        
        mockWebSocketManager.isConnected = true
        
        // When
        sut.send(message: message) { result in
            // Then
            switch result {
            case .success:
                XCTAssertTrue(self.mockWebSocketManager.sendCalled)
                XCTAssertEqual(self.mockWebSocketManager.sentMessage?.id, message.id)
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
    }
    
    func test_send_message_connectionNotAvailable_returnsError() {
        // Given
        let message = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: "Hello, World!".data(using: .utf8)!,
            timestamp: Date()
        )
        
        mockWebSocketManager.isConnected = false
        
        // When
        sut.send(message: message) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected error but got success")
            case .failure(let error):
                XCTAssertEqual(error, .connectionNotAvailable)
            }
        }
    }
    
    func test_send_message_webSocketFailure_returnsError() {
        // Given
        let message = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: "Hello, World!".data(using: .utf8)!,
            timestamp: Date()
        )
        
        mockWebSocketManager.isConnected = true
        mockWebSocketManager.shouldSend = false
        mockWebSocketManager.error = MessageError.sendFailed(NSError(domain: "test", code: 1))
        
        // When
        sut.send(message: message) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected error but got success")
            case .failure(let error):
                XCTAssertEqual(error, .sendFailed(mockWebSocketManager.error!))
            }
        }
    }
    
    // MARK: - Message Handler Tests
    
    func test_onMessage_setsMessageHandler() {
        // Given
        var receivedMessage: RealTimeMessage?
        let expectedMessage = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: "Test message".data(using: .utf8)!,
            timestamp: Date()
        )
        
        // When
        sut.onMessage { message in
            receivedMessage = message
        }
        
        // Simulate message received
        mockWebSocketManager.simulateMessageReceived(expectedMessage)
        
        // Then
        XCTAssertEqual(receivedMessage?.id, expectedMessage.id)
        XCTAssertEqual(receivedMessage?.type, expectedMessage.type)
    }
    
    // MARK: - Push Notification Tests
    
    func test_onPushNotification_setsNotificationHandler() {
        // Given
        var receivedNotification: PushNotification?
        let expectedNotification = PushNotification(
            id: UUID(),
            title: "Test Title",
            body: "Test Body",
            data: ["key": "value"],
            timestamp: Date()
        )
        
        // When
        sut.onPushNotification { notification in
            receivedNotification = notification
        }
        
        // Simulate notification received
        mockPushNotificationManager.simulateNotificationReceived(expectedNotification)
        
        // Then
        XCTAssertEqual(receivedNotification?.id, expectedNotification.id)
        XCTAssertEqual(receivedNotification?.title, expectedNotification.title)
    }
    
    // MARK: - Health Metrics Tests
    
    func test_getHealthMetrics_returnsCurrentMetrics() {
        // Given
        let expectedMetrics = ConnectionHealthMetrics(
            connectionStatus: .connected,
            latency: 100.0,
            throughput: 1000.0,
            errorRate: 0.01,
            lastStatusUpdate: Date()
        )
        
        mockConnectionManager.healthMetrics = expectedMetrics
        
        // When
        let metrics = sut.getHealthMetrics()
        
        // Then
        XCTAssertEqual(metrics.connectionStatus, expectedMetrics.connectionStatus)
        XCTAssertEqual(metrics.latency, expectedMetrics.latency)
        XCTAssertEqual(metrics.throughput, expectedMetrics.throughput)
        XCTAssertEqual(metrics.errorRate, expectedMetrics.errorRate)
    }
    
    // MARK: - Analytics Tests
    
    func test_getAnalytics_returnsCurrentAnalytics() {
        // Given
        let expectedAnalytics = AnalyticsData(
            totalMessages: 100,
            successfulMessages: 95,
            failedMessages: 5,
            averageLatency: 150.0,
            connectionUptime: 3600.0,
            lastUpdated: Date()
        )
        
        mockAnalyticsManager.analyticsData = expectedAnalytics
        
        // When
        let analytics = sut.getAnalytics()
        
        // Then
        XCTAssertEqual(analytics.totalMessages, expectedAnalytics.totalMessages)
        XCTAssertEqual(analytics.successfulMessages, expectedAnalytics.successfulMessages)
        XCTAssertEqual(analytics.failedMessages, expectedAnalytics.failedMessages)
        XCTAssertEqual(analytics.averageLatency, expectedAnalytics.averageLatency)
        XCTAssertEqual(analytics.connectionUptime, expectedAnalytics.connectionUptime)
    }
    
    // MARK: - Connection Status Tests
    
    func test_connectionStatus_whenConnected_returnsConnected() async {
        // Given
        mockWebSocketManager.isConnected = true
        
        // When
        let status = sut.connectionStatus
        
        // Then
        XCTAssertEqual(status, .connected)
    }
    
    func test_connectionStatus_whenDisconnected_returnsDisconnected() async {
        // Given
        mockWebSocketManager.isConnected = false
        
        // When
        let status = sut.connectionStatus
        
        // Then
        XCTAssertEqual(status, .disconnected)
    }
    
    // MARK: - Error Handling Tests
    
    func test_webSocketError_notifiesDelegate() {
        // Given
        let testError = NSError(domain: "test", code: 1, userInfo: nil)
        var receivedError: Error?
        
        sut.delegate = MockRealTimeManagerDelegate { error in
            receivedError = error
        }
        
        // When
        mockWebSocketManager.simulateError(testError)
        
        // Then
        XCTAssertEqual(receivedError as? NSError, testError)
    }
    
    func test_pushNotificationError_notifiesDelegate() {
        // Given
        let testError = NSError(domain: "test", code: 2, userInfo: nil)
        var receivedError: Error?
        
        sut.delegate = MockRealTimeManagerDelegate { error in
            receivedError = error
        }
        
        // When
        mockPushNotificationManager.simulateError(testError)
        
        // Then
        XCTAssertEqual(receivedError as? NSError, testError)
    }
}

// MARK: - Mock Classes

private class MockWebSocketManager: WebSocketManager {
    var shouldConnect = true
    var shouldDisconnect = true
    var shouldSend = true
    var isConnected = false
    var error: Error?
    var sendCalled = false
    var sentMessage: RealTimeMessage?
    
    override func connect() async throws -> WebSocketConnectionResult {
        if shouldConnect {
            isConnected = true
            return WebSocketConnectionResult(
                sessionID: UUID().uuidString,
                serverURL: "wss://test.com",
                connectionTime: Date()
            )
        } else {
            throw error ?? ConnectionError.networkUnavailable
        }
    }
    
    override func disconnect() async throws {
        if shouldDisconnect {
            isConnected = false
        } else {
            throw error ?? ConnectionError.disconnectionFailed(NSError(domain: "test", code: 1))
        }
    }
    
    override func send(message: RealTimeMessage) throws {
        sendCalled = true
        sentMessage = message
        
        if shouldSend {
            // Success
        } else {
            throw error ?? MessageError.sendFailed(NSError(domain: "test", code: 1))
        }
    }
    
    func simulateMessageReceived(_ message: RealTimeMessage) {
        onMessage?(message)
    }
    
    func simulateError(_ error: Error) {
        delegate?.webSocketManager(self, didEncounterError: error)
    }
}

private class MockPushNotificationManager: PushNotificationManager {
    var shouldRegister = true
    var shouldUnregister = true
    var error: Error?
    var onNotification: ((PushNotification) -> Void)?
    
    override func register() async throws {
        if shouldRegister {
            // Success
        } else {
            throw error ?? ConnectionError.authenticationFailed
        }
    }
    
    override func unregister() async throws {
        if shouldUnregister {
            // Success
        } else {
            throw error ?? ConnectionError.disconnectionFailed(NSError(domain: "test", code: 1))
        }
    }
    
    func simulateNotificationReceived(_ notification: PushNotification) {
        onNotification?(notification)
    }
    
    func simulateError(_ error: Error) {
        delegate?.pushNotificationManager(self, didEncounterError: error)
    }
}

private class MockMessageQueueManager: MessageQueueManager {
    var shouldProcess = true
    var error: Error?
    
    override func startProcessing() {
        // Success
    }
    
    override func stopProcessing() {
        // Success
    }
    
    override func addMessage(_ message: RealTimeMessage, priority: MessagePriority) throws {
        if shouldProcess {
            // Success
        } else {
            throw error ?? MessageError.queueFull
        }
    }
}

private class MockAnalyticsManager: AnalyticsManager {
    var analyticsData = AnalyticsData(
        totalMessages: 0,
        successfulMessages: 0,
        failedMessages: 0,
        averageLatency: 0.0,
        connectionUptime: 0.0,
        lastUpdated: Date()
    )
    
    override func getAnalytics() -> AnalyticsData {
        return analyticsData
    }
}

private class MockConnectionManager: ConnectionManager {
    var healthMetrics = ConnectionHealthMetrics(
        connectionStatus: .disconnected,
        latency: 0.0,
        throughput: 0.0,
        errorRate: 0.0,
        lastStatusUpdate: Date()
    )
    
    override func getHealthMetrics() -> ConnectionHealthMetrics {
        return healthMetrics
    }
}

private class MockRealTimeManagerDelegate: RealTimeManagerDelegate {
    private let errorHandler: (Error) -> Void
    
    init(errorHandler: @escaping (Error) -> Void) {
        self.errorHandler = errorHandler
    }
    
    func realTimeManager(_ manager: RealTimeManager, didEncounterError error: Error) {
        errorHandler(error)
    }
} 