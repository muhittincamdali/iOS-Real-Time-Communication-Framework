import XCTest
@testable import RealTimeCommunication

final class WebSocketManagerTests: XCTestCase {
    
    private var sut: WebSocketManager!
    private var mockConfiguration: RealTimeConfig!
    
    override func setUp() {
        super.setUp()
        
        mockConfiguration = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key"
        )
        
        sut = WebSocketManager(configuration: mockConfiguration)
    }
    
    override func tearDown() {
        sut = nil
        mockConfiguration = nil
        super.tearDown()
    }
    
    func test_init_withConfiguration_createsManagerWithCorrectConfiguration() {
        XCTAssertNotNil(sut)
        XCTAssertFalse(sut.isConnected)
    }
    
    func test_connect_success_returnsConnectionResult() async throws {
        // Given
        let expectedSessionID = UUID().uuidString
        
        // When
        let result = try await sut.connect()
        
        // Then
        XCTAssertEqual(result.serverURL, mockConfiguration.serverURL)
        XCTAssertNotNil(result.sessionID)
        XCTAssertNotNil(result.connectionTime)
    }
    
    func test_disconnect_success_completesWithoutError() async {
        // When & Then
        do {
            try await sut.disconnect()
            XCTAssertTrue(true) // No error thrown
        } catch {
            XCTFail("Expected no error but got: \(error)")
        }
    }
    
    func test_send_message_success_sendsMessage() {
        // Given
        let message = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: "Hello, World!".data(using: .utf8)!,
            timestamp: Date()
        )
        
        // When & Then
        do {
            try sut.send(message: message)
            XCTAssertTrue(true) // No error thrown
        } catch {
            XCTFail("Expected no error but got: \(error)")
        }
    }
    
    func test_isConnected_whenNotConnected_returnsFalse() {
        XCTAssertFalse(sut.isConnected)
    }
} 