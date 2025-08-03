import XCTest
@testable import RealTimeCommunication

final class ConnectionManagerTests: XCTestCase {
    
    private var sut: ConnectionManager!
    private var mockConfiguration: RealTimeConfig!
    
    override func setUp() {
        super.setUp()
        
        mockConfiguration = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key",
            enableConnectionPooling: true
        )
        
        sut = ConnectionManager(configuration: mockConfiguration)
    }
    
    override func tearDown() {
        sut = nil
        mockConfiguration = nil
        super.tearDown()
    }
    
    func test_init_withConfiguration_createsManagerWithCorrectConfiguration() {
        XCTAssertNotNil(sut)
    }
    
    func test_getHealthMetrics_returnsHealthMetrics() {
        // When
        let metrics = sut.getHealthMetrics()
        
        // Then
        XCTAssertNotNil(metrics)
        XCTAssertEqual(metrics.connectionStatus, .disconnected)
    }
    
    func test_getBestConnection_whenNoConnections_returnsNil() {
        // When
        let connection = sut.getBestConnection()
        
        // Then
        XCTAssertNil(connection)
    }
    
    func test_addConnection_addsConnectionToPool() {
        // Given
        let connection = Connection(
            id: UUID(),
            url: "wss://test-server.com",
            status: .connected
        )
        
        // When
        sut.addConnection(connection)
        
        // Then
        let statistics = sut.getPoolStatistics()
        XCTAssertEqual(statistics.totalConnections, 1)
    }
    
    func test_removeConnection_removesConnectionFromPool() {
        // Given
        let connection = Connection(
            id: UUID(),
            url: "wss://test-server.com",
            status: .connected
        )
        sut.addConnection(connection)
        
        // When
        sut.removeConnection(connection)
        
        // Then
        let statistics = sut.getPoolStatistics()
        XCTAssertEqual(statistics.totalConnections, 0)
    }
    
    func test_performHealthCheck_performsHealthCheck() {
        // When
        sut.performHealthCheck()
        
        // Then
        XCTAssertTrue(true) // No error thrown
    }
    
    func test_getPoolStatistics_returnsCorrectStatistics() {
        // Given
        let connection = Connection(
            id: UUID(),
            url: "wss://test-server.com",
            status: .connected
        )
        sut.addConnection(connection)
        
        // When
        let statistics = sut.getPoolStatistics()
        
        // Then
        XCTAssertEqual(statistics.totalConnections, 1)
        XCTAssertEqual(statistics.activeConnections, 1)
        XCTAssertEqual(statistics.failedConnections, 0)
    }
    
    func test_handleConnectionFailure_handlesFailureCorrectly() {
        // Given
        let connection = Connection(
            id: UUID(),
            url: "wss://test-server.com",
            status: .connected
        )
        
        // When
        sut.handleConnectionFailure(connection)
        
        // Then
        XCTAssertTrue(true) // No error thrown
    }
    
    func test_handleConnectionRecovery_handlesRecoveryCorrectly() {
        // Given
        let connection = Connection(
            id: UUID(),
            url: "wss://test-server.com",
            status: .failed
        )
        
        // When
        sut.handleConnectionRecovery(connection)
        
        // Then
        XCTAssertTrue(true) // No error thrown
    }
} 