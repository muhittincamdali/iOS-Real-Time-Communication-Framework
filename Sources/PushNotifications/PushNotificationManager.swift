import Foundation
import UserNotifications
import UIKit

/// Manages push notifications for the real-time communication system
///
/// This class handles the registration, delivery, and processing of push notifications
/// using Apple Push Notification service (APNs). It provides a high-level interface
/// for push notification management with automatic token refresh and delivery tracking.
///
/// ## Usage
///
/// ```swift
/// let manager = PushNotificationManager(configuration: config)
/// try await manager.register()
/// ```
public class PushNotificationManager {
    
    // MARK: - Properties
    
    /// Configuration for the push notification manager
    private let configuration: RealTimeConfig
    
    /// Delegate for push notification events
    public weak var delegate: PushNotificationManagerDelegate?
    
    /// Analytics delegate for tracking events
    public weak var analyticsDelegate: AnalyticsDelegate?
    
    /// Notification handler for received notifications
    public var onNotification: ((PushNotification) -> Void)?
    
    /// Logger for debugging and monitoring
    private let logger: Logger
    
    /// Current device token
    private var deviceToken: String?
    
    /// Registration state
    private var registrationState: RegistrationState = .notRegistered
    
    /// Notification categories
    private var notificationCategories: Set<UNNotificationCategory> = []
    
    /// Background task identifier
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
    
    // MARK: - Initialization
    
    /// Creates a new push notification manager with the specified configuration
    /// - Parameter configuration: The configuration for the push notification manager
    public init(configuration: RealTimeConfig) {
        self.configuration = configuration
        self.logger = Logger(label: "com.realtime.push")
        
        setupNotificationCategories()
        
        logger.info("PushNotificationManager initialized with configuration: \(configuration)")
    }
    
    // MARK: - Public Methods
    
    /// Registers for push notifications
    /// - Throws: `PushNotificationError` if registration fails
    public func register() async throws {
        logger.info("Registering for push notifications")
        
        do {
            // Request authorization
            let granted = try await requestAuthorization()
            
            guard granted else {
                throw PushNotificationError.authorizationDenied
            }
            
            // Register for remote notifications
            await registerForRemoteNotifications()
            
            // Update registration state
            registrationState = .registered
            
            // Track analytics
            analyticsDelegate?.trackEvent(.pushNotificationRegistered, properties: [
                "device_token": deviceToken ?? "unknown",
                "registration_time": Date().timeIntervalSince1970
            ])
            
            logger.info("Successfully registered for push notifications")
            
            // Notify delegate
            if let deviceToken = deviceToken {
                delegate?.pushNotificationManager(self, didRegister: deviceToken)
            }
            
        } catch {
            logger.error("Failed to register for push notifications: \(error)")
            
            // Track analytics
            analyticsDelegate?.trackEvent(.pushNotificationRegistrationFailed, properties: [
                "error": error.localizedDescription
            ])
            
            throw PushNotificationError.registrationFailed(error)
        }
    }
    
    /// Unregisters from push notifications
    /// - Throws: `PushNotificationError` if unregistration fails
    public func unregister() async throws {
        logger.info("Unregistering from push notifications")
        
        do {
            // Unregister from remote notifications
            await unregisterFromRemoteNotifications()
            
            // Clear device token
            deviceToken = nil
            
            // Update registration state
            registrationState = .notRegistered
            
            // Track analytics
            analyticsDelegate?.trackEvent(.pushNotificationUnregistered, properties: [
                "unregistration_time": Date().timeIntervalSince1970
            ])
            
            logger.info("Successfully unregistered from push notifications")
            
        } catch {
            logger.error("Failed to unregister from push notifications: \(error)")
            
            // Track analytics
            analyticsDelegate?.trackEvent(.pushNotificationUnregistrationFailed, properties: [
                "error": error.localizedDescription
            ])
            
            throw PushNotificationError.unregistrationFailed(error)
        }
    }
    
    /// Sets the device token for push notifications
    /// - Parameter deviceToken: The device token from APNs
    public func setDeviceToken(_ deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = tokenString
        
        logger.info("Device token set: \(tokenString)")
        
        // Track analytics
        analyticsDelegate?.trackEvent(.deviceTokenReceived, properties: [
            "device_token": tokenString,
            "token_length": deviceToken.count
        ])
    }
    
    /// Handles a received push notification
    /// - Parameter userInfo: The notification user info
    public func handleNotification(_ userInfo: [AnyHashable: Any]) {
        logger.info("Handling push notification: \(userInfo)")
        
        do {
            // Parse notification
            let notification = try parseNotification(userInfo)
            
            // Process notification
            processNotification(notification)
            
            // Track analytics
            analyticsDelegate?.trackEvent(.pushNotificationReceived, properties: [
                "notification_id": notification.id.uuidString,
                "notification_type": notification.type.rawValue,
                "delivery_time": Date().timeIntervalSince1970
            ])
            
            // Notify delegate
            delegate?.pushNotificationManager(self, didReceiveNotification: notification)
            
            // Call notification handler
            onNotification?(notification)
            
        } catch {
            logger.error("Failed to handle push notification: \(error)")
            
            // Track analytics
            analyticsDelegate?.trackEvent(.pushNotificationProcessingFailed, properties: [
                "error": error.localizedDescription
            ])
            
            // Notify delegate
            delegate?.pushNotificationManager(self, didEncounterError: error)
        }
    }
    
    /// Schedules a local notification
    /// - Parameter notification: The notification to schedule
    /// - Throws: `PushNotificationError` if scheduling fails
    public func scheduleLocalNotification(_ notification: LocalNotification) throws {
        logger.info("Scheduling local notification: \(notification)")
        
        do {
            // Create UNNotificationRequest
            let request = try createNotificationRequest(from: notification)
            
            // Schedule notification
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    self.logger.error("Failed to schedule local notification: \(error)")
                    
                    // Track analytics
                    self.analyticsDelegate?.trackEvent(.localNotificationSchedulingFailed, properties: [
                        "error": error.localizedDescription
                    ])
                } else {
                    self.logger.info("Local notification scheduled successfully")
                    
                    // Track analytics
                    self.analyticsDelegate?.trackEvent(.localNotificationScheduled, properties: [
                        "notification_id": notification.id.uuidString
                    ])
                }
            }
            
        } catch {
            logger.error("Failed to create notification request: \(error)")
            throw PushNotificationError.schedulingFailed(error)
        }
    }
    
    /// Cancels a scheduled local notification
    /// - Parameter notificationID: The ID of the notification to cancel
    public func cancelLocalNotification(withID notificationID: String) {
        logger.info("Canceling local notification: \(notificationID)")
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
        
        // Track analytics
        analyticsDelegate?.trackEvent(.localNotificationCanceled, properties: [
            "notification_id": notificationID
        ])
    }
    
    /// Gets the current registration state
    /// - Returns: The current registration state
    public func getRegistrationState() -> RegistrationState {
        return registrationState
    }
    
    /// Gets the current device token
    /// - Returns: The current device token, or nil if not registered
    public func getDeviceToken() -> String? {
        return deviceToken
    }
    
    // MARK: - Private Methods
    
    /// Requests authorization for push notifications
    /// - Returns: True if authorized, false otherwise
    /// - Throws: `PushNotificationError` if authorization fails
    private func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        do {
            let granted = try await center.requestAuthorization(options: options)
            
            logger.info("Push notification authorization granted: \(granted)")
            
            return granted
            
        } catch {
            logger.error("Failed to request push notification authorization: \(error)")
            throw PushNotificationError.authorizationFailed(error)
        }
    }
    
    /// Registers for remote notifications
    private func registerForRemoteNotifications() async {
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    /// Unregisters from remote notifications
    private func unregisterFromRemoteNotifications() async {
        await MainActor.run {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
    /// Sets up notification categories
    private func setupNotificationCategories() {
        // Create notification categories for different types
        let messageCategory = UNNotificationCategory(
            identifier: "MESSAGE",
            actions: [
                UNNotificationAction(
                    identifier: "REPLY",
                    title: "Reply",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: "MARK_READ",
                    title: "Mark as Read",
                    options: []
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let systemCategory = UNNotificationCategory(
            identifier: "SYSTEM",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW",
                    title: "View",
                    options: [.foreground]
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCategories = [messageCategory, systemCategory]
        
        // Register categories
        UNUserNotificationCenter.current().setNotificationCategories(notificationCategories)
        
        logger.debug("Notification categories setup completed")
    }
    
    /// Parses a push notification from user info
    /// - Parameter userInfo: The notification user info
    /// - Returns: A parsed push notification
    /// - Throws: `PushNotificationError` if parsing fails
    private func parseNotification(_ userInfo: [AnyHashable: Any]) throws -> PushNotification {
        guard let aps = userInfo["aps"] as? [String: Any] else {
            throw PushNotificationError.invalidNotificationFormat
        }
        
        let id = UUID()
        let title = aps["alert"] as? [String: Any]? ?? userInfo["title"] as? String ?? "Notification"
        let body = aps["alert"] as? String ?? aps["alert"] as? [String: Any]? ?? userInfo["body"] as? String ?? ""
        let badge = aps["badge"] as? Int
        let sound = aps["sound"] as? String
        let category = aps["category"] as? String
        let data = userInfo["data"] as? [String: Any] ?? [:]
        let timestamp = Date()
        
        return PushNotification(
            id: id,
            title: title,
            body: body,
            badge: badge,
            sound: sound,
            category: category,
            data: data,
            timestamp: timestamp
        )
    }
    
    /// Processes a received notification
    /// - Parameter notification: The notification to process
    private func processNotification(_ notification: PushNotification) {
        // Handle different notification types
        switch notification.category {
        case "MESSAGE":
            handleMessageNotification(notification)
        case "SYSTEM":
            handleSystemNotification(notification)
        default:
            handleDefaultNotification(notification)
        }
    }
    
    /// Handles message notifications
    /// - Parameter notification: The message notification
    private func handleMessageNotification(_ notification: PushNotification) {
        logger.info("Processing message notification: \(notification)")
        
        // Extract message data
        if let messageData = notification.data["message"] as? [String: Any] {
            // Process message data
            // Implementation depends on specific requirements
        }
    }
    
    /// Handles system notifications
    /// - Parameter notification: The system notification
    private func handleSystemNotification(_ notification: PushNotification) {
        logger.info("Processing system notification: \(notification)")
        
        // Handle system-level notifications
        // Implementation depends on specific requirements
    }
    
    /// Handles default notifications
    /// - Parameter notification: The default notification
    private func handleDefaultNotification(_ notification: PushNotification) {
        logger.info("Processing default notification: \(notification)")
        
        // Handle notifications without specific category
        // Implementation depends on specific requirements
    }
    
    /// Creates a notification request from a local notification
    /// - Parameter notification: The local notification
    /// - Returns: A UNNotificationRequest
    /// - Throws: `PushNotificationError` if creation fails
    private func createNotificationRequest(from notification: LocalNotification) throws -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = notification.sound != nil ? UNNotificationSound.default : nil
        content.badge = notification.badge as NSNumber?
        content.categoryIdentifier = notification.category ?? "DEFAULT"
        content.userInfo = notification.userInfo
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: notification.timeInterval,
            repeats: false
        )
        
        return UNNotificationRequest(
            identifier: notification.id.uuidString,
            content: content,
            trigger: trigger
        )
    }
}

// MARK: - Supporting Types

/// Registration state for push notifications
public enum RegistrationState {
    case notRegistered
    case registering
    case registered
    case unregistering
}

/// Push notification error types
public enum PushNotificationError: Error, LocalizedError {
    case authorizationFailed(Error)
    case authorizationDenied
    case registrationFailed(Error)
    case unregistrationFailed(Error)
    case schedulingFailed(Error)
    case invalidNotificationFormat
    case deviceTokenNotAvailable
    
    public var errorDescription: String? {
        switch self {
        case .authorizationFailed(let error):
            return "Authorization failed: \(error.localizedDescription)"
        case .authorizationDenied:
            return "Push notification authorization denied"
        case .registrationFailed(let error):
            return "Registration failed: \(error.localizedDescription)"
        case .unregistrationFailed(let error):
            return "Unregistration failed: \(error.localizedDescription)"
        case .schedulingFailed(let error):
            return "Scheduling failed: \(error.localizedDescription)"
        case .invalidNotificationFormat:
            return "Invalid notification format"
        case .deviceTokenNotAvailable:
            return "Device token not available"
        }
    }
}

/// Push notification manager delegate
public protocol PushNotificationManagerDelegate: AnyObject {
    func pushNotificationManager(_ manager: PushNotificationManager, didRegister deviceToken: String)
    func pushNotificationManager(_ manager: PushNotificationManager, didReceiveNotification notification: PushNotification)
    func pushNotificationManager(_ manager: PushNotificationManager, didEncounterError error: Error)
}

/// Push notification model
public struct PushNotification {
    public let id: UUID
    public let title: String
    public let body: String
    public let badge: Int?
    public let sound: String?
    public let category: String?
    public let data: [String: Any]
    public let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        body: String,
        badge: Int? = nil,
        sound: String? = nil,
        category: String? = nil,
        data: [String: Any] = [:],
        timestamp: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.badge = badge
        self.sound = sound
        self.category = category
        self.data = data
        self.timestamp = timestamp
    }
}

/// Local notification model
public struct LocalNotification {
    public let id: UUID
    public let title: String
    public let body: String
    public let timeInterval: TimeInterval
    public let sound: String?
    public let badge: Int?
    public let category: String?
    public let userInfo: [String: Any]
    
    public init(
        id: UUID = UUID(),
        title: String,
        body: String,
        timeInterval: TimeInterval,
        sound: String? = nil,
        badge: Int? = nil,
        category: String? = nil,
        userInfo: [String: Any] = [:]
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.timeInterval = timeInterval
        self.sound = sound
        self.badge = badge
        self.category = category
        self.userInfo = userInfo
    }
} 