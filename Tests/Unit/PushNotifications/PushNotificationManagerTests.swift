import XCTest
@testable import RealTimeCommunication

final class PushNotificationManagerTests: XCTestCase {
    
    private var sut: PushNotificationManager!
    private var mockConfiguration: RealTimeConfig!
    
    override func setUp() {
        super.setUp()
        
        mockConfiguration = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key",
            enablePushNotifications: true
        )
        
        sut = PushNotificationManager(configuration: mockConfiguration)
    }
    
    override func tearDown() {
        sut = nil
        mockConfiguration = nil
        super.tearDown()
    }
    
    func test_init_withConfiguration_createsManagerWithCorrectConfiguration() {
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.getRegistrationState(), .notRegistered)
    }
    
    func test_register_success_registersForPushNotifications() async throws {
        // When & Then
        do {
            try await sut.register()
            XCTAssertTrue(true) // No error thrown
        } catch {
            XCTFail("Expected no error but got: \(error)")
        }
    }
    
    func test_unregister_success_unregistersFromPushNotifications() async throws {
        // When & Then
        do {
            try await sut.unregister()
            XCTAssertTrue(true) // No error thrown
        } catch {
            XCTFail("Expected no error but got: \(error)")
        }
    }
    
    func test_setDeviceToken_setsTokenCorrectly() {
        // Given
        let deviceToken = "test-device-token".data(using: .utf8)!
        
        // When
        sut.setDeviceToken(deviceToken)
        
        // Then
        XCTAssertNotNil(sut.getDeviceToken())
    }
    
    func test_getRegistrationState_returnsCorrectState() {
        XCTAssertEqual(sut.getRegistrationState(), .notRegistered)
    }
} 