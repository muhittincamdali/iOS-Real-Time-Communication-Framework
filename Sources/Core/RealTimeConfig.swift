import Foundation

/// Configuration for the real-time communication system
///
/// This struct contains all the configuration options needed to set up
/// the real-time communication framework, including server URLs, API keys,
/// and feature flags.
///
/// ## Usage
///
/// ```swift
/// let config = RealTimeConfig(
///     serverURL: "wss://your-server.com",
///     apiKey: "your-api-key",
///     enablePushNotifications: true,
///     enableAnalytics: true
/// )
/// ```
public struct RealTimeConfig {
    
    // MARK: - Server Configuration
    
    /// The WebSocket server URL
    public let serverURL: String
    
    /// The API key for authentication
    public let apiKey: String
    
    /// The server port (optional, defaults to 443 for WSS, 80 for WS)
    public let port: Int?
    
    /// The server path (optional, defaults to "/")
    public let path: String
    
    // MARK: - Connection Configuration
    
    /// Connection timeout in seconds
    public let connectionTimeout: TimeInterval
    
    /// Heartbeat interval in seconds
    public let heartbeatInterval: TimeInterval
    
    /// Maximum reconnection attempts
    public let maxReconnectionAttempts: Int
    
    /// Reconnection delay in seconds
    public let reconnectionDelay: TimeInterval
    
    /// Exponential backoff multiplier for reconnection
    public let reconnectionBackoffMultiplier: Double
    
    // MARK: - Feature Flags
    
    /// Whether to enable push notifications
    public let enablePushNotifications: Bool
    
    /// Whether to enable analytics
    public let enableAnalytics: Bool
    
    /// Whether to enable message queuing
    public let enableMessageQueuing: Bool
    
    /// Whether to enable connection pooling
    public let enableConnectionPooling: Bool
    
    // MARK: - Security Configuration
    
    /// Whether to enable SSL/TLS encryption
    public let enableEncryption: Bool
    
    /// Certificate pinning configuration
    public let certificatePinning: CertificatePinningConfig?
    
    /// Token authentication configuration
    public let tokenAuthentication: TokenAuthenticationConfig?
    
    // MARK: - Performance Configuration
    
    /// Maximum message size in bytes
    public let maxMessageSize: Int
    
    /// Message processing batch size
    public let messageBatchSize: Int
    
    /// Connection pool size
    public let connectionPoolSize: Int
    
    /// Analytics flush interval in seconds
    public let analyticsFlushInterval: TimeInterval
    
    // MARK: - Logging Configuration
    
    /// Log level for the framework
    public let logLevel: LogLevel
    
    /// Whether to enable debug logging
    public let enableDebugLogging: Bool
    
    // MARK: - Initialization
    
    /// Creates a new configuration with the specified parameters
    /// - Parameters:
    ///   - serverURL: The WebSocket server URL
    ///   - apiKey: The API key for authentication
    ///   - port: The server port (optional)
    ///   - path: The server path (optional)
    ///   - connectionTimeout: Connection timeout in seconds (default: 30)
    ///   - heartbeatInterval: Heartbeat interval in seconds (default: 30)
    ///   - maxReconnectionAttempts: Maximum reconnection attempts (default: 5)
    ///   - reconnectionDelay: Reconnection delay in seconds (default: 1)
    ///   - reconnectionBackoffMultiplier: Exponential backoff multiplier (default: 2.0)
    ///   - enablePushNotifications: Whether to enable push notifications (default: true)
    ///   - enableAnalytics: Whether to enable analytics (default: true)
    ///   - enableMessageQueuing: Whether to enable message queuing (default: true)
    ///   - enableConnectionPooling: Whether to enable connection pooling (default: true)
    ///   - enableEncryption: Whether to enable SSL/TLS encryption (default: true)
    ///   - certificatePinning: Certificate pinning configuration (optional)
    ///   - tokenAuthentication: Token authentication configuration (optional)
    ///   - maxMessageSize: Maximum message size in bytes (default: 1024 * 1024)
    ///   - messageBatchSize: Message processing batch size (default: 100)
    ///   - connectionPoolSize: Connection pool size (default: 5)
    ///   - analyticsFlushInterval: Analytics flush interval in seconds (default: 60)
    ///   - logLevel: Log level for the framework (default: .info)
    ///   - enableDebugLogging: Whether to enable debug logging (default: false)
    public init(
        serverURL: String,
        apiKey: String,
        port: Int? = nil,
        path: String = "/",
        connectionTimeout: TimeInterval = 30,
        heartbeatInterval: TimeInterval = 30,
        maxReconnectionAttempts: Int = 5,
        reconnectionDelay: TimeInterval = 1,
        reconnectionBackoffMultiplier: Double = 2.0,
        enablePushNotifications: Bool = true,
        enableAnalytics: Bool = true,
        enableMessageQueuing: Bool = true,
        enableConnectionPooling: Bool = true,
        enableEncryption: Bool = true,
        certificatePinning: CertificatePinningConfig? = nil,
        tokenAuthentication: TokenAuthenticationConfig? = nil,
        maxMessageSize: Int = 1024 * 1024,
        messageBatchSize: Int = 100,
        connectionPoolSize: Int = 5,
        analyticsFlushInterval: TimeInterval = 60,
        logLevel: LogLevel = .info,
        enableDebugLogging: Bool = false
    ) {
        self.serverURL = serverURL
        self.apiKey = apiKey
        self.port = port
        self.path = path
        self.connectionTimeout = connectionTimeout
        self.heartbeatInterval = heartbeatInterval
        self.maxReconnectionAttempts = maxReconnectionAttempts
        self.reconnectionDelay = reconnectionDelay
        self.reconnectionBackoffMultiplier = reconnectionBackoffMultiplier
        self.enablePushNotifications = enablePushNotifications
        self.enableAnalytics = enableAnalytics
        self.enableMessageQueuing = enableMessageQueuing
        self.enableConnectionPooling = enableConnectionPooling
        self.enableEncryption = enableEncryption
        self.certificatePinning = certificatePinning
        self.tokenAuthentication = tokenAuthentication
        self.maxMessageSize = maxMessageSize
        self.messageBatchSize = messageBatchSize
        self.connectionPoolSize = connectionPoolSize
        self.analyticsFlushInterval = analyticsFlushInterval
        self.logLevel = logLevel
        self.enableDebugLogging = enableDebugLogging
    }
    
    /// Creates a default configuration for development
    /// - Returns: A default configuration suitable for development
    public static func development() -> RealTimeConfig {
        return RealTimeConfig(
            serverURL: "ws://localhost:8080",
            apiKey: "dev-api-key",
            enableDebugLogging: true,
            logLevel: .debug
        )
    }
    
    /// Creates a default configuration for production
    /// - Returns: A default configuration suitable for production
    public static func production() -> RealTimeConfig {
        return RealTimeConfig(
            serverURL: "wss://api.realtime.com",
            apiKey: "prod-api-key",
            enableDebugLogging: false,
            logLevel: .warning
        )
    }
}

// MARK: - Supporting Types

/// Log level for the framework
public enum LogLevel: String, CaseIterable {
    case debug = "debug"
    case info = "info"
    case warning = "warning"
    case error = "error"
    case critical = "critical"
}

/// Certificate pinning configuration
public struct CertificatePinningConfig {
    
    /// The certificate hashes to pin
    public let certificateHashes: [String]
    
    /// Whether to enable certificate pinning
    public let enabled: Bool
    
    /// Creates a new certificate pinning configuration
    /// - Parameters:
    ///   - certificateHashes: The certificate hashes to pin
    ///   - enabled: Whether to enable certificate pinning
    public init(certificateHashes: [String], enabled: Bool = true) {
        self.certificateHashes = certificateHashes
        self.enabled = enabled
    }
}

/// Token authentication configuration
public struct TokenAuthenticationConfig {
    
    /// The authentication token
    public let token: String
    
    /// The token refresh URL
    public let refreshURL: String?
    
    /// The token expiration time
    public let expirationTime: Date?
    
    /// Whether to enable automatic token refresh
    public let enableAutoRefresh: Bool
    
    /// Creates a new token authentication configuration
    /// - Parameters:
    ///   - token: The authentication token
    ///   - refreshURL: The token refresh URL (optional)
    ///   - expirationTime: The token expiration time (optional)
    ///   - enableAutoRefresh: Whether to enable automatic token refresh
    public init(
        token: String,
        refreshURL: String? = nil,
        expirationTime: Date? = nil,
        enableAutoRefresh: Bool = true
    ) {
        self.token = token
        self.refreshURL = refreshURL
        self.expirationTime = expirationTime
        self.enableAutoRefresh = enableAutoRefresh
    }
} 