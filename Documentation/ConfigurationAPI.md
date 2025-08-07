# Configuration API

## Overview

The Configuration API provides comprehensive configuration management for iOS applications using the Real-Time Communication Framework. This document covers all public interfaces, classes, and methods available in the Configuration module.

## Table of Contents

- [ConfigurationManager](#configurationmanager)
- [RealTimeCommunicationConfiguration](#realtimemunicationconfiguration)
- [WebSocketConfiguration](#websocketconfiguration)
- [SocketIOConfiguration](#socketioconfiguration)
- [FirebaseConfiguration](#firebaseconfiguration)
- [PushNotificationConfiguration](#pushnotificationconfiguration)
- [VoiceVideoConfiguration](#voicevideoconfiguration)
- [SecurityConfiguration](#securityconfiguration)
- [ConfigurationError](#configurationerror)

## ConfigurationManager

The main configuration manager class that coordinates all configuration settings.

### Initialization

```swift
let configManager = ConfigurationManager()
```

### Configuration Management

```swift
func configure(_ configuration: RealTimeCommunicationConfiguration)
```

Configures the framework with the specified configuration.

**Parameters:**
- `configuration`: The real-time communication configuration object

**Example:**
```swift
let config = RealTimeCommunicationConfiguration()
config.enableWebSocket = true
config.enableSocketIO = true
config.enableFirebase = true
config.enablePushNotifications = true

configManager.configure(config)
```

### Configuration Validation

```swift
func validateConfiguration(_ configuration: RealTimeCommunicationConfiguration) -> Result<Void, ConfigurationError>
```

Validates a configuration object.

**Parameters:**
- `configuration`: The configuration to validate

**Returns:**
- Result indicating validation success or failure

**Example:**
```swift
let validationResult = configManager.validateConfiguration(config)
switch validationResult {
case .success:
    print("✅ Configuration is valid")
case .failure(let error):
    print("❌ Configuration validation failed: \(error)")
}
```

### Configuration Persistence

```swift
func saveConfiguration(_ configuration: RealTimeCommunicationConfiguration, completion: @escaping (Result<Void, ConfigurationError>) -> Void)
```

Saves configuration to persistent storage.

**Parameters:**
- `configuration`: The configuration to save
- `completion`: Completion handler called with the save result

**Example:**
```swift
configManager.saveConfiguration(config) { result in
    switch result {
    case .success:
        print("✅ Configuration saved")
    case .failure(let error):
        print("❌ Configuration save failed: \(error)")
    }
}
```

```swift
func loadConfiguration(completion: @escaping (Result<RealTimeCommunicationConfiguration, ConfigurationError>) -> Void)
```

Loads configuration from persistent storage.

**Parameters:**
- `completion`: Completion handler called with the load result

**Example:**
```swift
configManager.loadConfiguration { result in
    switch result {
    case .success(let config):
        print("✅ Configuration loaded")
        self.applyConfiguration(config)
    case .failure(let error):
        print("❌ Configuration load failed: \(error)")
    }
}
```

### Configuration Reset

```swift
func resetConfiguration(completion: @escaping (Result<Void, ConfigurationError>) -> Void)
```

Resets configuration to default values.

**Parameters:**
- `completion`: Completion handler called with the reset result

**Example:**
```swift
configManager.resetConfiguration { result in
    switch result {
    case .success:
        print("✅ Configuration reset to defaults")
    case .failure(let error):
        print("❌ Configuration reset failed: \(error)")
    }
}
```

## RealTimeCommunicationConfiguration

Main configuration class for the Real-Time Communication Framework.

### Properties

```swift
var enableWebSocket: Bool
```

Whether to enable WebSocket functionality.

```swift
var enableSocketIO: Bool
```

Whether to enable Socket.IO functionality.

```swift
var enableFirebase: Bool
```

Whether to enable Firebase functionality.

```swift
var enablePushNotifications: Bool
```

Whether to enable push notifications.

```swift
var enableVoiceVideo: Bool
```

Whether to enable voice and video calls.

```swift
var enableSecurity: Bool
```

Whether to enable security features.

```swift
var enableAnalytics: Bool
```

Whether to enable analytics.

```swift
var enableLogging: Bool
```

Whether to enable logging.

```swift
var connectionTimeout: TimeInterval
```

The connection timeout in seconds.

```swift
var maxReconnectionAttempts: Int
```

The maximum number of reconnection attempts.

```swift
var enableHeartbeat: Bool
```

Whether to enable connection heartbeat.

```swift
var heartbeatInterval: TimeInterval
```

The heartbeat interval in seconds.

```swift
var enableEncryption: Bool
```

Whether to enable encryption.

```swift
var enableAuthentication: Bool
```

Whether to enable authentication.

```swift
var enableSSL: Bool
```

Whether to enable SSL/TLS.

### Example

```swift
let config = RealTimeCommunicationConfiguration()
config.enableWebSocket = true
config.enableSocketIO = true
config.enableFirebase = true
config.enablePushNotifications = true
config.enableVoiceVideo = true
config.enableSecurity = true
config.enableAnalytics = true
config.enableLogging = true
config.connectionTimeout = 30
config.maxReconnectionAttempts = 5
config.enableHeartbeat = true
config.heartbeatInterval = 30
config.enableEncryption = true
config.enableAuthentication = true
config.enableSSL = true
```

## WebSocketConfiguration

Configuration class for WebSocket settings.

### Properties

```swift
var url: String
```

The WebSocket server URL.

```swift
var enableReconnection: Bool
```

Whether to enable automatic reconnection.

```swift
var heartbeatInterval: TimeInterval
```

The heartbeat interval in seconds.

```swift
var maxReconnectionAttempts: Int
```

The maximum number of reconnection attempts.

```swift
var reconnectionDelay: TimeInterval
```

The delay between reconnection attempts.

```swift
var enableSSL: Bool
```

Whether to enable SSL/TLS.

```swift
var enableCertificatePinning: Bool
```

Whether to enable certificate pinning.

```swift
var customHeaders: [String: String]
```

Custom headers to include in the WebSocket handshake.

```swift
var enableCompression: Bool
```

Whether to enable message compression.

```swift
var maxMessageSize: Int
```

The maximum message size in bytes.

### Example

```swift
let wsConfig = WebSocketConfiguration()
wsConfig.url = "wss://api.company.com/ws"
wsConfig.enableReconnection = true
wsConfig.heartbeatInterval = 30
wsConfig.maxReconnectionAttempts = 5
wsConfig.reconnectionDelay = 1000
wsConfig.enableSSL = true
wsConfig.enableCertificatePinning = true
wsConfig.customHeaders = [
    "Authorization": "Bearer token",
    "User-Agent": "iOS-WebSocket-Client"
]
wsConfig.enableCompression = true
wsConfig.maxMessageSize = 1024 * 1024 // 1MB
```

## SocketIOConfiguration

Configuration class for Socket.IO settings.

### Properties

```swift
var serverURL: String
```

The Socket.IO server URL.

```swift
var path: String
```

The Socket.IO path (default: "/socket.io/").

```swift
var port: Int
```

The Socket.IO server port.

```swift
var enableReconnection: Bool
```

Whether to enable automatic reconnection.

```swift
var reconnectionAttempts: Int
```

The maximum number of reconnection attempts.

```swift
var reconnectionDelay: TimeInterval
```

The delay between reconnection attempts in milliseconds.

```swift
var reconnectionDelayMax: TimeInterval
```

The maximum delay between reconnection attempts.

```swift
var timeout: TimeInterval
```

The connection timeout in milliseconds.

```swift
var transport: SocketIOTransport
```

The transport protocol to use.

```swift
var enableForceNew: Bool
```

Whether to force a new connection.

```swift
var enableMultiplex: Bool
```

Whether to enable connection multiplexing.

```swift
var enableSSL: Bool
```

Whether to enable SSL/TLS.

```swift
var enableCertificatePinning: Bool
```

Whether to enable certificate pinning.

```swift
var customHeaders: [String: String]
```

Custom headers to include in the connection.

```swift
var queryParameters: [String: String]
```

Query parameters to include in the connection.

```swift
var namespace: String
```

The Socket.IO namespace to connect to.

```swift
var enableCompression: Bool
```

Whether to enable message compression.

```swift
var enableBinaryMessages: Bool
```

Whether to enable binary message support.

```swift
var maxPayload: Int
```

The maximum payload size in bytes.

### Example

```swift
let socketIOConfig = SocketIOConfiguration()
socketIOConfig.serverURL = "https://api.company.com"
socketIOConfig.path = "/socket.io/"
socketIOConfig.port = 443
socketIOConfig.enableReconnection = true
socketIOConfig.reconnectionAttempts = 5
socketIOConfig.reconnectionDelay = 1000
socketIOConfig.reconnectionDelayMax = 5000
socketIOConfig.timeout = 20000
socketIOConfig.transport = .websocket
socketIOConfig.enableForceNew = true
socketIOConfig.enableMultiplex = false
socketIOConfig.enableSSL = true
socketIOConfig.enableCertificatePinning = true
socketIOConfig.customHeaders = [
    "Authorization": "Bearer token",
    "User-Agent": "iOS-SocketIO-Client"
]
socketIOConfig.queryParameters = [
    "client": "ios",
    "version": "2.1.0"
]
socketIOConfig.namespace = "/chat"
socketIOConfig.enableCompression = true
socketIOConfig.enableBinaryMessages = true
socketIOConfig.maxPayload = 1000000 // 1MB
```

## FirebaseConfiguration

Configuration class for Firebase settings.

### Properties

```swift
var projectID: String
```

The Firebase project identifier.

```swift
var bundleID: String
```

The iOS app bundle identifier.

```swift
var enableAnalytics: Bool
```

Whether to enable Firebase Analytics.

```swift
var enableMessaging: Bool
```

Whether to enable Firebase Cloud Messaging.

```swift
var enableDatabase: Bool
```

Whether to enable Firebase Realtime Database.

```swift
var enableAuthentication: Bool
```

Whether to enable Firebase Authentication.

```swift
var enableStorage: Bool
```

Whether to enable Firebase Storage.

```swift
var enableFunctions: Bool
```

Whether to enable Firebase Functions.

```swift
var enablePerformanceMonitoring: Bool
```

Whether to enable Firebase Performance Monitoring.

```swift
var enableCrashlytics: Bool
```

Whether to enable Firebase Crashlytics.

```swift
var enableAppCheck: Bool
```

Whether to enable Firebase App Check.

```swift
var enableRemoteConfig: Bool
```

Whether to enable Firebase Remote Config.

### Example

```swift
let firebaseConfig = FirebaseConfiguration()
firebaseConfig.projectID = "your-project-id"
firebaseConfig.bundleID = "com.yourcompany.yourapp"
firebaseConfig.enableAnalytics = true
firebaseConfig.enableMessaging = true
firebaseConfig.enableDatabase = true
firebaseConfig.enableAuthentication = true
firebaseConfig.enableStorage = true
firebaseConfig.enableFunctions = true
firebaseConfig.enablePerformanceMonitoring = true
firebaseConfig.enableCrashlytics = true
firebaseConfig.enableAppCheck = true
firebaseConfig.enableRemoteConfig = true
```

## PushNotificationConfiguration

Configuration class for push notification settings.

### Properties

```swift
var enableAPNs: Bool
```

Whether to enable Apple Push Notification service.

```swift
var enableFCM: Bool
```

Whether to enable Firebase Cloud Messaging.

```swift
var enableRichNotifications: Bool
```

Whether to enable rich notifications.

```swift
var enableSilentNotifications: Bool
```

Whether to enable silent notifications.

```swift
var enableBadge: Bool
```

Whether to enable badge management.

```swift
var enableSound: Bool
```

Whether to enable sound notifications.

```swift
var enableAlert: Bool
```

Whether to enable alert notifications.

```swift
var enableCriticalAlerts: Bool
```

Whether to enable critical alerts.

```swift
var enableProvisional: Bool
```

Whether to enable provisional notifications.

```swift
var enableAnnouncements: Bool
```

Whether to enable announcement notifications.

### Example

```swift
let pushConfig = PushNotificationConfiguration()
pushConfig.enableAPNs = true
pushConfig.enableFCM = true
pushConfig.enableRichNotifications = true
pushConfig.enableSilentNotifications = true
pushConfig.enableBadge = true
pushConfig.enableSound = true
pushConfig.enableAlert = true
pushConfig.enableCriticalAlerts = false
pushConfig.enableProvisional = false
pushConfig.enableAnnouncements = false
```

## VoiceVideoConfiguration

Configuration class for voice and video settings.

### Properties

```swift
var enableVoiceCalls: Bool
```

Whether to enable voice calls.

```swift
var enableVideoCalls: Bool
```

Whether to enable video calls.

```swift
var enableScreenSharing: Bool
```

Whether to enable screen sharing.

```swift
var enableRecording: Bool
```

Whether to enable call recording.

```swift
var enableEchoCancellation: Bool
```

Whether to enable echo cancellation.

```swift
var enableNoiseSuppression: Bool
```

Whether to enable noise suppression.

```swift
var enableAutomaticGainControl: Bool
```

Whether to enable automatic gain control.

```swift
var audioCodec: AudioCodec
```

The audio codec to use.

```swift
var videoCodec: VideoCodec
```

The video codec to use.

```swift
var resolution: VideoResolution
```

The video resolution.

```swift
var frameRate: Int
```

The video frame rate.

```swift
var bitrate: Int
```

The video bitrate in bps.

### Example

```swift
let voiceVideoConfig = VoiceVideoConfiguration()
voiceVideoConfig.enableVoiceCalls = true
voiceVideoConfig.enableVideoCalls = true
voiceVideoConfig.enableScreenSharing = true
voiceVideoConfig.enableRecording = true
voiceVideoConfig.enableEchoCancellation = true
voiceVideoConfig.enableNoiseSuppression = true
voiceVideoConfig.enableAutomaticGainControl = true
voiceVideoConfig.audioCodec = .opus
voiceVideoConfig.videoCodec = .h264
voiceVideoConfig.resolution = .hd720p
voiceVideoConfig.frameRate = 30
voiceVideoConfig.bitrate = 1000000 // 1 Mbps
```

## SecurityConfiguration

Configuration class for security settings.

### Properties

```swift
var enableEncryption: Bool
```

Whether to enable encryption.

```swift
var enableAuthentication: Bool
```

Whether to enable authentication.

```swift
var enableCertificatePinning: Bool
```

Whether to enable certificate pinning.

```swift
var enableTokenValidation: Bool
```

Whether to enable token validation.

```swift
var enableTokenEncryption: Bool
```

Whether to enable token encryption.

```swift
var enableBiometricAuth: Bool
```

Whether to enable biometric authentication.

```swift
var enableKeyRotation: Bool
```

Whether to enable key rotation.

```swift
var rotationInterval: TimeInterval
```

The key rotation interval in seconds.

```swift
var enableAuditLogging: Bool
```

Whether to enable audit logging.

```swift
var enableSecurityMonitoring: Bool
```

Whether to enable security monitoring.

### Example

```swift
let securityConfig = SecurityConfiguration()
securityConfig.enableEncryption = true
securityConfig.enableAuthentication = true
securityConfig.enableCertificatePinning = true
securityConfig.enableTokenValidation = true
securityConfig.enableTokenEncryption = true
securityConfig.enableBiometricAuth = true
securityConfig.enableKeyRotation = true
securityConfig.rotationInterval = 86400 // 24 hours
securityConfig.enableAuditLogging = true
securityConfig.enableSecurityMonitoring = true
```

## ConfigurationError

Represents configuration errors.

### Error Types

```swift
enum ConfigurationError: Error {
    case invalidConfiguration(String)
    case missingRequiredParameter(String)
    case invalidParameterValue(String, String)
    case configurationConflict(String)
    case persistenceFailed(String)
    case loadFailed(String)
    case validationFailed(String)
    case unsupportedFeature(String)
}
```

### Properties

```swift
var localizedDescription: String
```

A human-readable description of the error.

```swift
var code: Int
```

The error code.

### Example

```swift
configManager.onError { error in
    switch error {
    case .invalidConfiguration(let detail):
        print("❌ Invalid configuration: \(detail)")
    case .missingRequiredParameter(let parameter):
        print("❌ Missing required parameter: \(parameter)")
    case .invalidParameterValue(let parameter, let value):
        print("❌ Invalid value for parameter \(parameter): \(value)")
    case .configurationConflict(let conflict):
        print("❌ Configuration conflict: \(conflict)")
    case .persistenceFailed(let reason):
        print("❌ Configuration persistence failed: \(reason)")
    case .loadFailed(let reason):
        print("❌ Configuration load failed: \(reason)")
    case .validationFailed(let reason):
        print("❌ Configuration validation failed: \(reason)")
    case .unsupportedFeature(let feature):
        print("❌ Unsupported feature: \(feature)")
    }
}
```

## Complete Example

```swift
import RealTimeCommunication

class ConfigurationManager: ObservableObject {
    private let configManager = ConfigurationManager()
    
    @Published var currentConfiguration: RealTimeCommunicationConfiguration?
    @Published var isConfigurationValid = false
    @Published var lastConfigurationError: String = ""
    
    init() {
        setupConfiguration()
    }
    
    private func setupConfiguration() {
        // Create default configuration
        let config = RealTimeCommunicationConfiguration()
        config.enableWebSocket = true
        config.enableSocketIO = true
        config.enableFirebase = true
        config.enablePushNotifications = true
        config.enableVoiceVideo = true
        config.enableSecurity = true
        config.enableAnalytics = true
        config.enableLogging = true
        config.connectionTimeout = 30
        config.maxReconnectionAttempts = 5
        config.enableHeartbeat = true
        config.heartbeatInterval = 30
        config.enableEncryption = true
        config.enableAuthentication = true
        config.enableSSL = true
        
        // Validate configuration
        let validationResult = configManager.validateConfiguration(config)
        switch validationResult {
        case .success:
            isConfigurationValid = true
            currentConfiguration = config
            applyConfiguration(config)
        case .failure(let error):
            isConfigurationValid = false
            lastConfigurationError = error.localizedDescription
            print("❌ Configuration validation failed: \(error)")
        }
    }
    
    func applyConfiguration(_ config: RealTimeCommunicationConfiguration) {
        configManager.configure(config)
        currentConfiguration = config
        isConfigurationValid = true
        lastConfigurationError = ""
    }
    
    func saveConfiguration(_ config: RealTimeCommunicationConfiguration) {
        configManager.saveConfiguration(config) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.currentConfiguration = config
                    self.isConfigurationValid = true
                    self.lastConfigurationError = ""
                    print("✅ Configuration saved")
                case .failure(let error):
                    self.isConfigurationValid = false
                    self.lastConfigurationError = error.localizedDescription
                    print("❌ Configuration save failed: \(error)")
                }
            }
        }
    }
    
    func loadConfiguration() {
        configManager.loadConfiguration { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let config):
                    self.currentConfiguration = config
                    self.isConfigurationValid = true
                    self.lastConfigurationError = ""
                    self.applyConfiguration(config)
                    print("✅ Configuration loaded")
                case .failure(let error):
                    self.isConfigurationValid = false
                    self.lastConfigurationError = error.localizedDescription
                    print("❌ Configuration load failed: \(error)")
                }
            }
        }
    }
    
    func resetConfiguration() {
        configManager.resetConfiguration { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.setupConfiguration()
                    print("✅ Configuration reset to defaults")
                case .failure(let error):
                    self.isConfigurationValid = false
                    self.lastConfigurationError = error.localizedDescription
                    print("❌ Configuration reset failed: \(error)")
                }
            }
        }
    }
    
    func updateWebSocketConfiguration(_ wsConfig: WebSocketConfiguration) {
        guard var config = currentConfiguration else { return }
        
        // Update WebSocket configuration
        config.webSocketConfiguration = wsConfig
        
        // Validate and apply
        let validationResult = configManager.validateConfiguration(config)
        switch validationResult {
        case .success:
            applyConfiguration(config)
        case .failure(let error):
            isConfigurationValid = false
            lastConfigurationError = error.localizedDescription
        }
    }
    
    func updateSocketIOConfiguration(_ socketIOConfig: SocketIOConfiguration) {
        guard var config = currentConfiguration else { return }
        
        // Update Socket.IO configuration
        config.socketIOConfiguration = socketIOConfig
        
        // Validate and apply
        let validationResult = configManager.validateConfiguration(config)
        switch validationResult {
        case .success:
            applyConfiguration(config)
        case .failure(let error):
            isConfigurationValid = false
            lastConfigurationError = error.localizedDescription
        }
    }
    
    func updateFirebaseConfiguration(_ firebaseConfig: FirebaseConfiguration) {
        guard var config = currentConfiguration else { return }
        
        // Update Firebase configuration
        config.firebaseConfiguration = firebaseConfig
        
        // Validate and apply
        let validationResult = configManager.validateConfiguration(config)
        switch validationResult {
        case .success:
            applyConfiguration(config)
        case .failure(let error):
            isConfigurationValid = false
            lastConfigurationError = error.localizedDescription
        }
    }
}

struct ConfigurationView: View {
    @StateObject private var configManager = ConfigurationManager()
    @State private var showingWebSocketConfig = false
    @State private var showingSocketIOConfig = false
    @State private var showingFirebaseConfig = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Configuration status
                VStack {
                    HStack {
                        Circle()
                            .fill(configManager.isConfigurationValid ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text(configManager.isConfigurationValid ? "Valid" : "Invalid")
                    }
                    
                    if !configManager.lastConfigurationError.isEmpty {
                        Text("Error: \(configManager.lastConfigurationError)")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                
                // Configuration sections
                VStack(spacing: 15) {
                    Button("WebSocket Configuration") {
                        showingWebSocketConfig = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Socket.IO Configuration") {
                        showingSocketIOConfig = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Firebase Configuration") {
                        showingFirebaseConfig = true
                    }
                    .buttonStyle(.bordered)
                }
                
                // Actions
                VStack(spacing: 10) {
                    Button("Save Configuration") {
                        if let config = configManager.currentConfiguration {
                            configManager.saveConfiguration(config)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!configManager.isConfigurationValid)
                    
                    Button("Load Configuration") {
                        configManager.loadConfiguration()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Reset Configuration") {
                        configManager.resetConfiguration()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Configuration")
            .sheet(isPresented: $showingWebSocketConfig) {
                WebSocketConfigurationView()
            }
            .sheet(isPresented: $showingSocketIOConfig) {
                SocketIOConfigurationView()
            }
            .sheet(isPresented: $showingFirebaseConfig) {
                FirebaseConfigurationView()
            }
        }
    }
}

struct WebSocketConfigurationView: View {
    @State private var url = "wss://api.company.com/ws"
    @State private var enableReconnection = true
    @State private var heartbeatInterval = 30.0
    @State private var maxReconnectionAttempts = 5
    @State private var enableSSL = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Connection") {
                    TextField("WebSocket URL", text: $url)
                    Toggle("Enable Reconnection", isOn: $enableReconnection)
                    HStack {
                        Text("Heartbeat Interval")
                        Spacer()
                        TextField("Seconds", value: $heartbeatInterval, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("Max Reconnection Attempts")
                        Spacer()
                        TextField("Attempts", value: $maxReconnectionAttempts, format: .number)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section("Security") {
                    Toggle("Enable SSL", isOn: $enableSSL)
                }
            }
            .navigationTitle("WebSocket Configuration")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SocketIOConfigurationView: View {
    @State private var serverURL = "https://api.company.com"
    @State private var namespace = "/chat"
    @State private var enableReconnection = true
    @State private var reconnectionAttempts = 5
    @State private var enableSSL = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Connection") {
                    TextField("Server URL", text: $serverURL)
                    TextField("Namespace", text: $namespace)
                    Toggle("Enable Reconnection", isOn: $enableReconnection)
                    HStack {
                        Text("Reconnection Attempts")
                        Spacer()
                        TextField("Attempts", value: $reconnectionAttempts, format: .number)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section("Security") {
                    Toggle("Enable SSL", isOn: $enableSSL)
                }
            }
            .navigationTitle("Socket.IO Configuration")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FirebaseConfigurationView: View {
    @State private var projectID = "your-project-id"
    @State private var enableAnalytics = true
    @State private var enableMessaging = true
    @State private var enableDatabase = true
    @State private var enableAuthentication = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Project") {
                    TextField("Project ID", text: $projectID)
                }
                
                Section("Services") {
                    Toggle("Enable Analytics", isOn: $enableAnalytics)
                    Toggle("Enable Messaging", isOn: $enableMessaging)
                    Toggle("Enable Database", isOn: $enableDatabase)
                    Toggle("Enable Authentication", isOn: $enableAuthentication)
                }
            }
            .navigationTitle("Firebase Configuration")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
```

This comprehensive API documentation covers all aspects of the Configuration module in the iOS Real-Time Communication Framework. For more examples and advanced usage, refer to the Configuration Guide and other documentation.
