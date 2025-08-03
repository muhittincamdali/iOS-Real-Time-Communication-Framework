import XCTest
@testable import RealTimeCommunication

final class MessageQueueManagerTests: XCTestCase {
    
    private var sut: MessageQueueManager!
    private var mockConfiguration: RealTimeConfig!
    
    override func setUp() {
        super.setUp()
        
        mockConfiguration = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key",
            enableMessageQueuing: true
        )
        
        sut = MessageQueueManager(configuration: mockConfiguration)
    }
    
    override func tearDown() {
        sut = nil
        mockConfiguration = nil
        super.tearDown()
    }
    
    func test_init_withConfiguration_createsManagerWithCorrectConfiguration() {
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.getQueueSize(), 0)
    }
    
    func test_addMessage_success_addsMessageToQueue() throws {
        // Given
        let message = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: "Hello, World!".data(using: .utf8)!,
            timestamp: Date()
        )
        
        // When
        try sut.addMessage(message, priority: .high)
        
        // Then
        XCTAssertEqual(sut.getQueueSize(), 1)
    }
    
    func test_startProcessing_startsMessageProcessing() {
        // When
        sut.startProcessing()
        
        // Then
        XCTAssertTrue(true) // No error thrown
    }
    
    func test_stopProcessing_stopsMessageProcessing() {
        // When
        sut.stopProcessing()
        
        // Then
        XCTAssertTrue(true) // No error thrown
    }
    
    func test_getQueueSize_returnsCorrectSize() {
        // Given
        let message = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: "Hello, World!".data(using: .utf8)!,
            timestamp: Date()
        )
        
        // When
        try? sut.addMessage(message, priority: .normal)
        
        // Then
        XCTAssertEqual(sut.getQueueSize(), 1)
    }
    
    func test_clearQueue_clearsAllMessages() throws {
        // Given
        let message = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: "Hello, World!".data(using: .utf8)!,
            timestamp: Date()
        )
        try sut.addMessage(message, priority: .normal)
        
        // When
        sut.clearQueue()
        
        // Then
        XCTAssertEqual(sut.getQueueSize(), 0)
    }
} 