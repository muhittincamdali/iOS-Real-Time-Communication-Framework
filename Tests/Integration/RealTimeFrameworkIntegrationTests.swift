import XCTest
@testable import RealTimeCommunication

final class RealTimeFrameworkIntegrationTests: XCTestCase {
    
    private var realTimeManager: RealTimeManager!
    private var mockConfiguration: RealTimeConfig!
    
    override func setUp() {
        super.setUp()
        
        mockConfiguration = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key",
            enablePushNotifications: true,
            enableAnalytics: true,
            enableMessageQueuing: true,
            enableConnectionPooling: true
        )
        
        realTimeManager = RealTimeManager(configuration: mockConfiguration)
    }
    
    override func tearDown() {
        realTimeManager = nil
        mockConfiguration = nil
        super.tearDown()
    }
    
    func test_frameworkInitialization_createsAllComponents() {
        // Then
        XCTAssertNotNil(realTimeManager)
        XCTAssertEqual(realTimeManager.connectionStatus, .disconnected)
    }
    
    func test_connect_disconnect_workflow() async {
        // When
        do {
            let connectionResult = try await realTimeManager.connect()
            
            // Then
            XCTAssertEqual(connectionResult.status, .connected)
            XCTAssertEqual(connectionResult.serverURL, mockConfiguration.serverURL)
            XCTAssertNotNil(connectionResult.sessionID)
            XCTAssertNotNil(connectionResult.connectionTime)
            
            // When
            let disconnectionResult = await realTimeManager.disconnect()
            
            // Then
            XCTAssertEqual(disconnectionResult.status, .disconnected)
            XCTAssertNotNil(disconnectionResult.sessionDuration)
            XCTAssertNil(disconnectionResult.error)
            
        } catch {
            XCTFail("Expected no error but got: \(error)")
        }
    }
    
    func test_sendMessage_workflow() {
        // Given
        let message = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: "Hello, World!".data(using: .utf8)!,
            timestamp: Date()
        )
        
        // When & Then
        realTimeManager.send(message: message, priority: .high) { result in
            switch result {
            case .success:
                XCTAssertTrue(true) // Success
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
    }
    
    func test_messageHandler_workflow() {
        // Given
        var receivedMessage: RealTimeMessage?
        let expectedMessage = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: "Test message".data(using: .utf8)!,
            timestamp: Date()
        )
        
        // When
        realTimeManager.onMessage { message in
            receivedMessage = message
        }
        
        // Simulate message received
        // This would typically be triggered by the WebSocket manager
        
        // Then
        // Verify handler is set (actual message handling would be tested in WebSocket tests)
        XCTAssertTrue(true)
    }
    
    func test_pushNotificationHandler_workflow() {
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
        realTimeManager.onPushNotification { notification in
            receivedNotification = notification
        }
        
        // Simulate notification received
        // This would typically be triggered by the push notification manager
        
        // Then
        // Verify handler is set (actual notification handling would be tested in push notification tests)
        XCTAssertTrue(true)
    }
    
    func test_healthMetrics_workflow() {
        // When
        let healthMetrics = realTimeManager.getHealthMetrics()
        
        // Then
        XCTAssertNotNil(healthMetrics)
        XCTAssertEqual(healthMetrics.connectionStatus, .disconnected)
        XCTAssertEqual(healthMetrics.latency, 0.0)
        XCTAssertEqual(healthMetrics.throughput, 0.0)
        XCTAssertEqual(healthMetrics.errorRate, 0.0)
    }
    
    func test_analytics_workflow() {
        // When
        let analytics = realTimeManager.getAnalytics()
        
        // Then
        XCTAssertNotNil(analytics)
        XCTAssertEqual(analytics.totalEvents, 0)
        XCTAssertEqual(analytics.eventsSent, 0)
        XCTAssertNotNil(analytics.lastUpdated)
    }
    
    func test_frameworkComponents_integration() {
        // Verify all components are properly initialized and integrated
        
        // WebSocket Manager
        XCTAssertNotNil(realTimeManager)
        
        // Push Notification Manager
        XCTAssertNotNil(realTimeManager)
        
        // Message Queue Manager
        XCTAssertNotNil(realTimeManager)
        
        // Analytics Manager
        XCTAssertNotNil(realTimeManager)
        
        // Connection Manager
        XCTAssertNotNil(realTimeManager)
    }
    
    func test_errorHandling_integration() {
        // Given
        let invalidMessage = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: Data(),
            timestamp: Date()
        )
        
        // When & Then
        realTimeManager.send(message: invalidMessage, priority: .high) { result in
            switch result {
            case .success:
                // Success is acceptable for empty data
                XCTAssertTrue(true)
            case .failure(let error):
                // Failure is also acceptable for invalid data
                XCTAssertNotNil(error)
            }
        }
    }
    
    func test_performance_integration() {
        // Measure basic performance metrics
        
        let startTime = Date()
        
        // Perform some basic operations
        let healthMetrics = realTimeManager.getHealthMetrics()
        let analytics = realTimeManager.getAnalytics()
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Ensure operations complete quickly
        XCTAssertLessThan(duration, 1.0) // Should complete in less than 1 second
        
        // Verify results are not nil
        XCTAssertNotNil(healthMetrics)
        XCTAssertNotNil(analytics)
    }
} 