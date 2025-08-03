import XCTest
@testable import RealTimeCommunication

final class PerformanceTests: XCTestCase {
    
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
    
    func test_initializationPerformance() {
        measure {
            let manager = RealTimeManager(configuration: mockConfiguration)
            XCTAssertNotNil(manager)
        }
    }
    
    func test_messageSendingPerformance() {
        let message = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: "Hello, World!".data(using: .utf8)!,
            timestamp: Date()
        )
        
        measure {
            realTimeManager.send(message: message, priority: .high) { _ in }
        }
    }
    
    func test_healthMetricsRetrievalPerformance() {
        measure {
            let metrics = realTimeManager.getHealthMetrics()
            XCTAssertNotNil(metrics)
        }
    }
    
    func test_analyticsRetrievalPerformance() {
        measure {
            let analytics = realTimeManager.getAnalytics()
            XCTAssertNotNil(analytics)
        }
    }
    
    func test_messageQueuePerformance() {
        let messages = (0..<100).map { i in
            RealTimeMessage(
                id: UUID(),
                type: .text,
                data: "Message \(i)".data(using: .utf8)!,
                timestamp: Date()
            )
        }
        
        measure {
            for message in messages {
                realTimeManager.send(message: message, priority: .normal) { _ in }
            }
        }
    }
    
    func test_concurrentMessageSendingPerformance() {
        let messageCount = 50
        let expectation = XCTestExpectation(description: "Concurrent message sending")
        expectation.expectedFulfillmentCount = messageCount
        
        measure {
            for i in 0..<messageCount {
                let message = RealTimeMessage(
                    id: UUID(),
                    type: .text,
                    data: "Concurrent message \(i)".data(using: .utf8)!,
                    timestamp: Date()
                )
                
                realTimeManager.send(message: message, priority: .normal) { _ in
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    func test_memoryUsagePerformance() {
        var managers: [RealTimeManager] = []
        
        measure {
            for _ in 0..<10 {
                let manager = RealTimeManager(configuration: mockConfiguration)
                managers.append(manager)
            }
            
            managers.removeAll()
        }
    }
    
    func test_connectionLifecyclePerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Connection lifecycle")
            
            Task {
                do {
                    let connectionResult = try await realTimeManager.connect()
                    XCTAssertEqual(connectionResult.status, .connected)
                    
                    let disconnectionResult = await realTimeManager.disconnect()
                    XCTAssertEqual(disconnectionResult.status, .disconnected)
                    
                    expectation.fulfill()
                } catch {
                    XCTFail("Connection lifecycle failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    func test_largeMessagePerformance() {
        let largeData = Data(repeating: 0, count: 1024 * 1024) // 1MB
        let message = RealTimeMessage(
            id: UUID(),
            type: .binary,
            data: largeData,
            timestamp: Date()
        )
        
        measure {
            realTimeManager.send(message: message, priority: .high) { _ in }
        }
    }
    
    func test_analyticsTrackingPerformance() {
        let eventCount = 1000
        
        measure {
            for i in 0..<eventCount {
                let message = RealTimeMessage(
                    id: UUID(),
                    type: .text,
                    data: "Analytics message \(i)".data(using: .utf8)!,
                    timestamp: Date()
                )
                
                realTimeManager.send(message: message, priority: .normal) { _ in }
            }
        }
    }
    
    func test_errorHandlingPerformance() {
        let invalidMessage = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: Data(),
            timestamp: Date()
        )
        
        measure {
            realTimeManager.send(message: invalidMessage, priority: .high) { _ in }
        }
    }
} 