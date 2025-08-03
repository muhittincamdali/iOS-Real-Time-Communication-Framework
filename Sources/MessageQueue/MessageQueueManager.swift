import Foundation

/// Manages message queuing with persistence and priority support
///
/// This class handles the queuing, processing, and delivery of messages
/// with support for different priority levels, retry logic, and persistence.
/// It provides a robust message handling system that ensures reliable delivery.
///
/// ## Usage
///
/// ```swift
/// let manager = MessageQueueManager(configuration: config)
/// try manager.addMessage(message, priority: .high)
/// ```
public class MessageQueueManager {
    
    // MARK: - Properties
    
    /// Configuration for the message queue manager
    private let configuration: RealTimeConfig
    
    /// Delegate for message queue events
    public weak var delegate: MessageQueueManagerDelegate?
    
    /// Analytics delegate for tracking events
    public weak var analyticsDelegate: AnalyticsDelegate?
    
    /// Logger for debugging and monitoring
    private let logger: Logger
    
    /// Message queues for different priority levels
    private var highPriorityQueue: [QueuedMessage] = []
    private var normalPriorityQueue: [QueuedMessage] = []
    private var lowPriorityQueue: [QueuedMessage] = []
    
    /// Processing state
    private var isProcessing = false
    
    /// Processing queue
    private let processingQueue = DispatchQueue(label: "com.realtime.messagequeue.processing", qos: .userInitiated)
    
    /// Storage for persistent messages
    private let messageStorage: MessageStorage
    
    /// Retry configuration
    private let retryConfig: RetryConfiguration
    
    /// Dead letter queue for failed messages
    private var deadLetterQueue: [QueuedMessage] = []
    
    // MARK: - Initialization
    
    /// Creates a new message queue manager with the specified configuration
    /// - Parameter configuration: The configuration for the message queue manager
    public init(configuration: RealTimeConfig) {
        self.configuration = configuration
        self.logger = Logger(label: "com.realtime.messagequeue")
        self.messageStorage = MessageStorage()
        self.retryConfig = RetryConfiguration()
        
        loadPersistedMessages()
        
        logger.info("MessageQueueManager initialized with configuration: \(configuration)")
    }
    
    // MARK: - Public Methods
    
    /// Starts processing messages in the queue
    public func startProcessing() {
        guard !isProcessing else { return }
        
        isProcessing = true
        logger.info("Starting message queue processing")
        
        processingQueue.async { [weak self] in
            self?.processMessages()
        }
    }
    
    /// Stops processing messages in the queue
    public func stopProcessing() {
        isProcessing = false
        logger.info("Stopping message queue processing")
    }
    
    /// Adds a message to the queue
    /// - Parameters:
    ///   - message: The message to add
    ///   - priority: The priority of the message
    /// - Throws: `MessageError` if adding fails
    public func addMessage(_ message: RealTimeMessage, priority: MessagePriority = .normal) throws {
        logger.info("Adding message to queue with priority: \(priority)")
        
        do {
            // Create queued message
            let queuedMessage = QueuedMessage(
                id: UUID(),
                message: message,
                priority: priority,
                timestamp: Date(),
                retryCount: 0,
                maxRetries: retryConfig.maxRetries
            )
            
            // Add to appropriate queue
            addToQueue(queuedMessage, priority: priority)
            
            // Persist message
            try messageStorage.saveMessage(queuedMessage)
            
            // Track analytics
            analyticsDelegate?.trackEvent(.messageQueued, properties: [
                "message_id": message.id.uuidString,
                "priority": priority.rawValue,
                "queue_size": getQueueSize()
            ])
            
            logger.debug("Message added to queue: \(message.id)")
            
        } catch {
            logger.error("Failed to add message to queue: \(error)")
            
            // Track analytics
            analyticsDelegate?.trackEvent(.messageQueueFailed, properties: [
                "error": error.localizedDescription,
                "message_id": message.id.uuidString
            ])
            
            throw MessageError.queueFull
        }
    }
    
    /// Removes a message from the queue
    /// - Parameter messageID: The ID of the message to remove
    public func removeMessage(withID messageID: UUID) {
        logger.info("Removing message from queue: \(messageID)")
        
        // Remove from all queues
        highPriorityQueue.removeAll { $0.message.id == messageID }
        normalPriorityQueue.removeAll { $0.message.id == messageID }
        lowPriorityQueue.removeAll { $0.message.id == messageID }
        deadLetterQueue.removeAll { $0.message.id == messageID }
        
        // Remove from storage
        messageStorage.removeMessage(withID: messageID)
        
        // Track analytics
        analyticsDelegate?.trackEvent(.messageRemoved, properties: [
            "message_id": messageID.uuidString
        ])
    }
    
    /// Gets the current queue size
    /// - Returns: The total number of messages in all queues
    public func getQueueSize() -> Int {
        return highPriorityQueue.count + normalPriorityQueue.count + lowPriorityQueue.count
    }
    
    /// Gets the dead letter queue size
    /// - Returns: The number of messages in the dead letter queue
    public func getDeadLetterQueueSize() -> Int {
        return deadLetterQueue.count
    }
    
    /// Clears all messages from the queue
    public func clearQueue() {
        logger.info("Clearing all message queues")
        
        highPriorityQueue.removeAll()
        normalPriorityQueue.removeAll()
        lowPriorityQueue.removeAll()
        deadLetterQueue.removeAll()
        
        messageStorage.clearAllMessages()
        
        // Track analytics
        analyticsDelegate?.trackEvent(.queueCleared, properties: [
            "cleared_time": Date().timeIntervalSince1970
        ])
    }
    
    /// Retries failed messages from the dead letter queue
    /// - Parameter messageID: The ID of the message to retry, or nil for all messages
    public func retryFailedMessage(_ messageID: UUID? = nil) {
        logger.info("Retrying failed messages")
        
        let messagesToRetry = messageID != nil 
            ? deadLetterQueue.filter { $0.message.id == messageID }
            : deadLetterQueue
        
        for message in messagesToRetry {
            // Reset retry count
            var retriedMessage = message
            retriedMessage.retryCount = 0
            retriedMessage.timestamp = Date()
            
            // Move back to appropriate queue
            addToQueue(retriedMessage, priority: retriedMessage.priority)
            
            // Remove from dead letter queue
            deadLetterQueue.removeAll { $0.message.id == message.message.id }
            
            // Update storage
            messageStorage.updateMessage(retriedMessage)
        }
        
        // Track analytics
        analyticsDelegate?.trackEvent(.failedMessageRetried, properties: [
            "retried_count": messagesToRetry.count
        ])
    }
    
    /// Gets queue statistics
    /// - Returns: Queue statistics
    public func getQueueStatistics() -> QueueStatistics {
        return QueueStatistics(
            highPriorityCount: highPriorityQueue.count,
            normalPriorityCount: normalPriorityQueue.count,
            lowPriorityCount: lowPriorityQueue.count,
            deadLetterCount: deadLetterQueue.count,
            totalCount: getQueueSize() + deadLetterQueue.count,
            oldestMessage: getOldestMessage(),
            newestMessage: getNewestMessage()
        )
    }
    
    // MARK: - Private Methods
    
    /// Adds a message to the appropriate queue
    /// - Parameters:
    ///   - message: The message to add
    ///   - priority: The priority of the message
    private func addToQueue(_ message: QueuedMessage, priority: MessagePriority) {
        switch priority {
        case .high:
            highPriorityQueue.append(message)
        case .normal:
            normalPriorityQueue.append(message)
        case .low:
            lowPriorityQueue.append(message)
        }
    }
    
    /// Processes messages in the queue
    private func processMessages() {
        while isProcessing {
            // Get next message to process
            guard let message = getNextMessage() else {
                // No messages to process, wait a bit
                Thread.sleep(forTimeInterval: 0.1)
                continue
            }
            
            // Process the message
            processMessage(message)
        }
    }
    
    /// Gets the next message to process based on priority
    /// - Returns: The next message to process, or nil if no messages
    private func getNextMessage() -> QueuedMessage? {
        // Process in priority order: high -> normal -> low
        if let message = highPriorityQueue.first {
            highPriorityQueue.removeFirst()
            return message
        }
        
        if let message = normalPriorityQueue.first {
            normalPriorityQueue.removeFirst()
            return message
        }
        
        if let message = lowPriorityQueue.first {
            lowPriorityQueue.removeFirst()
            return message
        }
        
        return nil
    }
    
    /// Processes a single message
    /// - Parameter queuedMessage: The message to process
    private func processMessage(_ queuedMessage: QueuedMessage) {
        logger.debug("Processing message: \(queuedMessage.message.id)")
        
        do {
            // Attempt to send the message
            try sendMessage(queuedMessage.message)
            
            // Remove from storage
            messageStorage.removeMessage(withID: queuedMessage.message.id)
            
            // Notify delegate
            delegate?.messageQueueManager(self, didProcessMessage: queuedMessage.message)
            
            // Track analytics
            analyticsDelegate?.trackEvent(.messageProcessed, properties: [
                "message_id": queuedMessage.message.id.uuidString,
                "priority": queuedMessage.priority.rawValue,
                "processing_time": Date().timeIntervalSince(queuedMessage.timestamp)
            ])
            
        } catch {
            logger.error("Failed to process message: \(error)")
            
            // Handle retry logic
            handleMessageRetry(queuedMessage, error: error)
        }
    }
    
    /// Handles message retry logic
    /// - Parameters:
    ///   - queuedMessage: The message that failed
    ///   - error: The error that occurred
    private func handleMessageRetry(_ queuedMessage: QueuedMessage, error: Error) {
        var updatedMessage = queuedMessage
        updatedMessage.retryCount += 1
        
        if updatedMessage.retryCount < updatedMessage.maxRetries {
            // Retry the message
            logger.info("Retrying message \(queuedMessage.message.id) (attempt \(updatedMessage.retryCount)/\(updatedMessage.maxRetries))")
            
            // Add back to queue with delay
            let delay = retryConfig.getDelay(forAttempt: updatedMessage.retryCount)
            
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.addToQueue(updatedMessage, priority: updatedMessage.priority)
                self?.messageStorage.updateMessage(updatedMessage)
            }
            
            // Track analytics
            analyticsDelegate?.trackEvent(.messageRetried, properties: [
                "message_id": queuedMessage.message.id.uuidString,
                "retry_count": updatedMessage.retryCount,
                "max_retries": updatedMessage.maxRetries
            ])
            
        } else {
            // Move to dead letter queue
            logger.warning("Message \(queuedMessage.message.id) exceeded max retries, moving to dead letter queue")
            
            deadLetterQueue.append(updatedMessage)
            messageStorage.moveToDeadLetter(updatedMessage)
            
            // Notify delegate
            delegate?.messageQueueManager(self, didFailToProcessMessage: queuedMessage.message, error: error)
            
            // Track analytics
            analyticsDelegate?.trackEvent(.messageFailed, properties: [
                "message_id": queuedMessage.message.id.uuidString,
                "error": error.localizedDescription,
                "retry_count": updatedMessage.retryCount
            ])
        }
    }
    
    /// Sends a message (placeholder for actual sending logic)
    /// - Parameter message: The message to send
    /// - Throws: `MessageError` if sending fails
    private func sendMessage(_ message: RealTimeMessage) throws {
        // This would typically delegate to the WebSocket manager
        // For now, we'll simulate sending with a random chance of failure
        
        let random = Double.random(in: 0...1)
        if random < 0.1 { // 10% chance of failure
            throw MessageError.sendFailed(NSError(domain: "test", code: 1, userInfo: nil))
        }
        
        // Simulate network delay
        Thread.sleep(forTimeInterval: 0.01)
    }
    
    /// Loads persisted messages from storage
    private func loadPersistedMessages() {
        do {
            let messages = try messageStorage.loadAllMessages()
            
            for message in messages {
                addToQueue(message, priority: message.priority)
            }
            
            logger.info("Loaded \(messages.count) persisted messages")
            
        } catch {
            logger.error("Failed to load persisted messages: \(error)")
        }
    }
    
    /// Gets the oldest message in the queue
    /// - Returns: The oldest message, or nil if queue is empty
    private func getOldestMessage() -> QueuedMessage? {
        let allMessages = highPriorityQueue + normalPriorityQueue + lowPriorityQueue
        return allMessages.min { $0.timestamp < $1.timestamp }
    }
    
    /// Gets the newest message in the queue
    /// - Returns: The newest message, or nil if queue is empty
    private func getNewestMessage() -> QueuedMessage? {
        let allMessages = highPriorityQueue + normalPriorityQueue + lowPriorityQueue
        return allMessages.max { $0.timestamp < $1.timestamp }
    }
}

// MARK: - Supporting Types

/// Message priority levels
public enum MessagePriority: String, CaseIterable {
    case high = "high"
    case normal = "normal"
    case low = "low"
}

/// Queued message with metadata
public struct QueuedMessage {
    public let id: UUID
    public let message: RealTimeMessage
    public let priority: MessagePriority
    public let timestamp: Date
    public var retryCount: Int
    public let maxRetries: Int
    
    public init(
        id: UUID = UUID(),
        message: RealTimeMessage,
        priority: MessagePriority,
        timestamp: Date = Date(),
        retryCount: Int = 0,
        maxRetries: Int = 3
    ) {
        self.id = id
        self.message = message
        self.priority = priority
        self.timestamp = timestamp
        self.retryCount = retryCount
        self.maxRetries = maxRetries
    }
}

/// Retry configuration
public struct RetryConfiguration {
    public let maxRetries: Int
    public let baseDelay: TimeInterval
    public let maxDelay: TimeInterval
    public let backoffMultiplier: Double
    
    public init(
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 60.0,
        backoffMultiplier: Double = 2.0
    ) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.backoffMultiplier = backoffMultiplier
    }
    
    public func getDelay(forAttempt attempt: Int) -> TimeInterval {
        let delay = baseDelay * pow(backoffMultiplier, Double(attempt - 1))
        return min(delay, maxDelay)
    }
}

/// Queue statistics
public struct QueueStatistics {
    public let highPriorityCount: Int
    public let normalPriorityCount: Int
    public let lowPriorityCount: Int
    public let deadLetterCount: Int
    public let totalCount: Int
    public let oldestMessage: QueuedMessage?
    public let newestMessage: QueuedMessage?
}

/// Message queue manager delegate
public protocol MessageQueueManagerDelegate: AnyObject {
    func messageQueueManager(_ manager: MessageQueueManager, didProcessMessage message: RealTimeMessage)
    func messageQueueManager(_ manager: MessageQueueManager, didFailToProcessMessage message: RealTimeMessage, error: Error)
}

/// Message storage for persistence
private class MessageStorage {
    private let userDefaults = UserDefaults.standard
    private let messagesKey = "RealTimeMessageQueue"
    private let deadLetterKey = "RealTimeDeadLetterQueue"
    
    func saveMessage(_ message: QueuedMessage) throws {
        var messages = loadMessages()
        messages.append(message)
        saveMessages(messages)
    }
    
    func removeMessage(withID id: UUID) {
        var messages = loadMessages()
        messages.removeAll { $0.message.id == id }
        saveMessages(messages)
    }
    
    func updateMessage(_ message: QueuedMessage) {
        var messages = loadMessages()
        if let index = messages.firstIndex(where: { $0.message.id == message.message.id }) {
            messages[index] = message
            saveMessages(messages)
        }
    }
    
    func moveToDeadLetter(_ message: QueuedMessage) {
        var deadLetter = loadDeadLetter()
        deadLetter.append(message)
        saveDeadLetter(deadLetter)
        
        removeMessage(withID: message.message.id)
    }
    
    func loadAllMessages() throws -> [QueuedMessage] {
        return loadMessages()
    }
    
    func clearAllMessages() {
        saveMessages([])
        saveDeadLetter([])
    }
    
    private func loadMessages() -> [QueuedMessage] {
        guard let data = userDefaults.data(forKey: messagesKey),
              let messages = try? JSONDecoder().decode([QueuedMessage].self, from: data) else {
            return []
        }
        return messages
    }
    
    private func saveMessages(_ messages: [QueuedMessage]) {
        guard let data = try? JSONEncoder().encode(messages) else { return }
        userDefaults.set(data, forKey: messagesKey)
    }
    
    private func loadDeadLetter() -> [QueuedMessage] {
        guard let data = userDefaults.data(forKey: deadLetterKey),
              let messages = try? JSONDecoder().decode([QueuedMessage].self, from: data) else {
            return []
        }
        return messages
    }
    
    private func saveDeadLetter(_ messages: [QueuedMessage]) {
        guard let data = try? JSONEncoder().encode(messages) else { return }
        userDefaults.set(data, forKey: deadLetterKey)
    }
} 