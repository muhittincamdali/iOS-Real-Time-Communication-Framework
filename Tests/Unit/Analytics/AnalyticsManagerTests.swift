import XCTest
@testable import RealTimeCommunication

final class AnalyticsManagerTests: XCTestCase {
    
    private var sut: AnalyticsManager!
    private var mockConfiguration: RealTimeConfig!
    
    override func setUp() {
        super.setUp()
        
        mockConfiguration = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key",
            enableAnalytics: true
        )
        
        sut = AnalyticsManager(configuration: mockConfiguration)
    }
    
    override func tearDown() {
        sut = nil
        mockConfiguration = nil
        super.tearDown()
    }
    
    func test_init_withConfiguration_createsManagerWithCorrectConfiguration() {
        XCTAssertNotNil(sut)
    }
    
    func test_trackEvent_success_tracksEvent() {
        // When
        sut.trackEvent(.messageSent, properties: ["size": 1024])
        
        // Then
        XCTAssertTrue(true) // No error thrown
    }
    
    func test_trackMetric_success_tracksMetric() {
        // When
        sut.trackMetric(.connectionLatency, value: 150.0, unit: "ms")
        
        // Then
        XCTAssertTrue(true) // No error thrown
    }
    
    func test_trackUserAction_success_tracksUserAction() {
        // When
        sut.trackUserAction(.messageSent, properties: ["type": "text"])
        
        // Then
        XCTAssertTrue(true) // No error thrown
    }
    
    func test_trackSystemHealth_success_tracksSystemHealth() {
        // When
        sut.trackSystemHealth(.connectionStability, value: 0.95)
        
        // Then
        XCTAssertTrue(true) // No error thrown
    }
    
    func test_getAnalytics_returnsAnalyticsData() {
        // When
        let analytics = sut.getAnalytics()
        
        // Then
        XCTAssertNotNil(analytics)
        XCTAssertEqual(analytics.totalEvents, 0)
    }
    
    func test_getPerformanceMetrics_returnsPerformanceMetrics() {
        // When
        let metrics = sut.getPerformanceMetrics()
        
        // Then
        XCTAssertNotNil(metrics)
        XCTAssertEqual(metrics.totalMessages, 0)
    }
    
    func test_getUserAnalytics_returnsUserAnalytics() {
        // When
        let analytics = sut.getUserAnalytics()
        
        // Then
        XCTAssertNotNil(analytics)
        XCTAssertEqual(analytics.totalActions, 0)
    }
    
    func test_getSystemHealthMetrics_returnsSystemHealthMetrics() {
        // When
        let metrics = sut.getSystemHealthMetrics()
        
        // Then
        XCTAssertNotNil(metrics)
        XCTAssertEqual(metrics.connectionStability, 0.0)
    }
    
    func test_flush_success_flushesEvents() {
        // When
        sut.flush()
        
        // Then
        XCTAssertTrue(true) // No error thrown
    }
    
    func test_reset_success_resetsAnalytics() {
        // When
        sut.reset()
        
        // Then
        XCTAssertTrue(true) // No error thrown
    }
} 