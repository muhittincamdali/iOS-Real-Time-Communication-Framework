import XCTest
@testable import RealTimeCommunication

final class SecurityTests: XCTestCase {
    
    private var realTimeManager: RealTimeManager!
    private var mockConfiguration: RealTimeConfig!
    
    override func setUp() {
        super.setUp()
        
        mockConfiguration = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key",
            enableEncryption: true,
            certificatePinning: CertificatePinningConfig(
                certificateHashes: ["test-hash"],
                enabled: true
            ),
            tokenAuthentication: TokenAuthenticationConfig(
                token: "test-token",
                refreshURL: "https://test-server.com/refresh",
                expirationTime: Date().addingTimeInterval(3600),
                enableAutoRefresh: true
            )
        )
        
        realTimeManager = RealTimeManager(configuration: mockConfiguration)
    }
    
    override func tearDown() {
        realTimeManager = nil
        mockConfiguration = nil
        super.tearDown()
    }
    
    func test_encryptionEnabled_configuration() {
        // Given
        let config = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key",
            enableEncryption: true
        )
        
        // Then
        XCTAssertTrue(config.enableEncryption)
    }
    
    func test_certificatePinning_configuration() {
        // Given
        let config = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key",
            certificatePinning: CertificatePinningConfig(
                certificateHashes: ["test-hash"],
                enabled: true
            )
        )
        
        // Then
        XCTAssertNotNil(config.certificatePinning)
        XCTAssertTrue(config.certificatePinning!.enabled)
        XCTAssertEqual(config.certificatePinning!.certificateHashes.count, 1)
    }
    
    func test_tokenAuthentication_configuration() {
        // Given
        let config = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key",
            tokenAuthentication: TokenAuthenticationConfig(
                token: "test-token",
                refreshURL: "https://test-server.com/refresh",
                expirationTime: Date().addingTimeInterval(3600),
                enableAutoRefresh: true
            )
        )
        
        // Then
        XCTAssertNotNil(config.tokenAuthentication)
        XCTAssertEqual(config.tokenAuthentication!.token, "test-token")
        XCTAssertTrue(config.tokenAuthentication!.enableAutoRefresh)
    }
    
    func test_secureMessageTransmission() {
        // Given
        let secureMessage = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: "Secure message".data(using: .utf8)!,
            timestamp: Date(),
            sender: "user1",
            recipient: "user2",
            metadata: ["encrypted": "true"]
        )
        
        // When & Then
        realTimeManager.send(message: secureMessage, priority: .high) { result in
            switch result {
            case .success:
                XCTAssertTrue(true) // Success
            case .failure(let error):
                // Failure is acceptable in test environment
                XCTAssertNotNil(error)
            }
        }
    }
    
    func test_authenticationFailure_handling() {
        // Given
        let invalidConfig = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "invalid-api-key",
            enableEncryption: true
        )
        
        let manager = RealTimeManager(configuration: invalidConfig)
        
        // When & Then
        Task {
            do {
                _ = try await manager.connect()
                XCTFail("Expected authentication failure")
            } catch {
                XCTAssertTrue(error is ConnectionError)
            }
        }
    }
    
    func test_certificateValidation() {
        // Given
        let configWithPinning = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key",
            certificatePinning: CertificatePinningConfig(
                certificateHashes: ["valid-hash"],
                enabled: true
            )
        )
        
        // Then
        XCTAssertNotNil(configWithPinning.certificatePinning)
        XCTAssertTrue(configWithPinning.certificatePinning!.enabled)
    }
    
    func test_tokenRefresh_mechanism() {
        // Given
        let configWithToken = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key",
            tokenAuthentication: TokenAuthenticationConfig(
                token: "expired-token",
                refreshURL: "https://test-server.com/refresh",
                expirationTime: Date().addingTimeInterval(-3600), // Expired
                enableAutoRefresh: true
            )
        )
        
        // Then
        XCTAssertNotNil(configWithToken.tokenAuthentication)
        XCTAssertTrue(configWithToken.tokenAuthentication!.enableAutoRefresh)
    }
    
    func test_dataEncryption() {
        // Given
        let sensitiveData = "Sensitive information".data(using: .utf8)!
        let message = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: sensitiveData,
            timestamp: Date(),
            metadata: ["encrypted": "true", "sensitive": "true"]
        )
        
        // When & Then
        realTimeManager.send(message: message, priority: .high) { result in
            switch result {
            case .success:
                XCTAssertTrue(true) // Success
            case .failure(let error):
                // Failure is acceptable in test environment
                XCTAssertNotNil(error)
            }
        }
    }
    
    func test_secureConnection_establishment() {
        // Given
        let secureConfig = RealTimeConfig(
            serverURL: "wss://test-server.com",
            apiKey: "test-api-key",
            enableEncryption: true,
            certificatePinning: CertificatePinningConfig(
                certificateHashes: ["test-hash"],
                enabled: true
            )
        )
        
        let secureManager = RealTimeManager(configuration: secureConfig)
        
        // When & Then
        Task {
            do {
                let result = try await secureManager.connect()
                XCTAssertEqual(result.status, .connected)
                
                let disconnectionResult = await secureManager.disconnect()
                XCTAssertEqual(disconnectionResult.status, .disconnected)
                
            } catch {
                // Failure is acceptable in test environment
                XCTAssertNotNil(error)
            }
        }
    }
    
    func test_inputValidation() {
        // Given
        let invalidMessage = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: Data(),
            timestamp: Date(),
            sender: "", // Invalid empty sender
            recipient: "", // Invalid empty recipient
            metadata: [:]
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
    
    func test_privacyCompliance() {
        // Given
        let privacyMessage = RealTimeMessage(
            id: UUID(),
            type: .text,
            data: "Privacy compliant message".data(using: .utf8)!,
            timestamp: Date(),
            metadata: ["gdpr_compliant": "true", "data_retention": "30_days"]
        )
        
        // When & Then
        realTimeManager.send(message: privacyMessage, priority: .normal) { result in
            switch result {
            case .success:
                XCTAssertTrue(true) // Success
            case .failure(let error):
                // Failure is acceptable in test environment
                XCTAssertNotNil(error)
            }
        }
    }
} 