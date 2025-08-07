# Monitoring API

## Overview

The Monitoring API provides comprehensive monitoring and analytics capabilities for iOS applications using the Real-Time Communication Framework. This document covers all public interfaces, classes, and methods available in the Monitoring module.

## Table of Contents

- [MonitoringManager](#monitoringmanager)
- [AnalyticsManager](#analyticsmanager)
- [PerformanceManager](#performancemanager)
- [MetricsCollector](#metricscollector)
- [EventTracker](#eventtracker)
- [HealthMonitor](#healthmonitor)
- [MonitoringError](#monitoringerror)

## MonitoringManager

The main monitoring manager class that coordinates all monitoring services.

### Initialization

```swift
let monitoringManager = MonitoringManager()
```

### Configuration

```swift
func configure(_ configuration: MonitoringConfiguration)
```

Configures the monitoring manager with the specified configuration.

**Parameters:**
- `configuration`: The monitoring configuration object

**Example:**
```swift
let config = MonitoringConfiguration()
config.enableAnalytics = true
config.enablePerformanceMonitoring = true
config.enableHealthMonitoring = true
config.enableMetricsCollection = true

monitoringManager.configure(config)
```

### Service Management

```swift
func getAnalyticsManager() -> AnalyticsManager
```

Gets the analytics manager.

**Returns:**
- The analytics manager instance

```swift
func getPerformanceManager() -> PerformanceManager
```

Gets the performance manager.

**Returns:**
- The performance manager instance

```swift
func getMetricsCollector() -> MetricsCollector
```

Gets the metrics collector.

**Returns:**
- The metrics collector instance

```swift
func getEventTracker() -> EventTracker
```

Gets the event tracker.

**Returns:**
- The event tracker instance

```swift
func getHealthMonitor() -> HealthMonitor
```

Gets the health monitor.

**Returns:**
- The health monitor instance

## AnalyticsManager

Manages analytics and user behavior tracking.

### Initialization

```swift
let analyticsManager = AnalyticsManager()
```

### Configuration

```swift
func configure(_ configuration: AnalyticsConfiguration)
```

Configures the analytics manager.

**Parameters:**
- `configuration`: The analytics configuration object

**Example:**
```swift
let analyticsConfig = AnalyticsConfiguration()
analyticsConfig.enableUserTracking = true
analyticsConfig.enableEventTracking = true
analyticsConfig.enableSessionTracking = true
analyticsConfig.enableCrashReporting = true

analyticsManager.configure(analyticsConfig)
```

### Event Tracking

```swift
func trackEvent(_ event: AnalyticsEvent)
```

Tracks an analytics event.

**Parameters:**
- `event`: The analytics event to track

**Example:**
```swift
let event = AnalyticsEvent(
    name: "user_login",
    parameters: [
        "method": "email",
        "user_id": "123"
    ]
)

analyticsManager.trackEvent(event)
```

```swift
func trackScreenView(_ screenName: String, parameters: [String: Any]? = nil)
```

Tracks a screen view.

**Parameters:**
- `screenName`: The name of the screen
- `parameters`: Optional screen parameters

**Example:**
```swift
analyticsManager.trackScreenView("ChatScreen", parameters: [
    "room_id": "room_123",
    "user_count": 5
])
```

```swift
func trackUserAction(_ action: String, parameters: [String: Any]? = nil)
```

Tracks a user action.

**Parameters:**
- `action`: The user action
- `parameters`: Optional action parameters

**Example:**
```swift
analyticsManager.trackUserAction("send_message", parameters: [
    "message_length": 50,
    "room_id": "room_123"
])
```

### User Properties

```swift
func setUserProperty(_ value: String?, forName name: String)
```

Sets a user property.

**Parameters:**
- `value`: The property value
- `name`: The property name

**Example:**
```swift
analyticsManager.setUserProperty("premium", forName: "subscription_type")
analyticsManager.setUserProperty("true", forName: "is_premium")
```

```swift
func setUserID(_ userID: String)
```

Sets the user ID.

**Parameters:**
- `userID`: The user identifier

**Example:**
```swift
analyticsManager.setUserID("user_123")
```

### Session Management

```swift
func startSession()
```

Starts a new analytics session.

**Example:**
```swift
analyticsManager.startSession()
```

```swift
func endSession()
```

Ends the current analytics session.

**Example:**
```swift
analyticsManager.endSession()
```

## PerformanceManager

Manages performance monitoring and optimization.

### Initialization

```swift
let performanceManager = PerformanceManager()
```

### Configuration

```swift
func configure(_ configuration: PerformanceConfiguration)
```

Configures the performance manager.

**Parameters:**
- `configuration`: The performance configuration object

**Example:**
```swift
let performanceConfig = PerformanceConfiguration()
performanceConfig.enableNetworkMonitoring = true
performanceConfig.enableMemoryMonitoring = true
performanceConfig.enableCPUMonitoring = true
performanceConfig.enableBatteryMonitoring = true

performanceManager.configure(performanceConfig)
```

### Performance Monitoring

```swift
func startTrace(_ traceName: String) -> PerformanceTrace
```

Starts a performance trace.

**Parameters:**
- `traceName`: The name of the trace

**Returns:**
- A performance trace object

**Example:**
```swift
let trace = performanceManager.startTrace("user_action")
trace.setMetric("action_type", value: "button_click")

// End trace
trace.stop()
```

```swift
func monitorNetworkPerformance(_ completion: @escaping (NetworkPerformance) -> Void)
```

Monitors network performance.

**Parameters:**
- `completion`: Completion handler called with network performance data

**Example:**
```swift
performanceManager.monitorNetworkPerformance { performance in
    print("📊 Network latency: \(performance.latency)ms")
    print("📊 Network bandwidth: \(performance.bandwidth) bps")
    print("📊 Packet loss: \(performance.packetLoss)%")
}
```

```swift
func monitorMemoryUsage(_ completion: @escaping (MemoryUsage) -> Void)
```

Monitors memory usage.

**Parameters:**
- `completion`: Completion handler called with memory usage data

**Example:**
```swift
performanceManager.monitorMemoryUsage { usage in
    print("📊 Memory used: \(usage.usedMemory) MB")
    print("📊 Memory available: \(usage.availableMemory) MB")
    print("📊 Memory pressure: \(usage.memoryPressure)")
}
```

```swift
func monitorCPUUsage(_ completion: @escaping (CPUUsage) -> Void)
```

Monitors CPU usage.

**Parameters:**
- `completion`: Completion handler called with CPU usage data

**Example:**
```swift
performanceManager.monitorCPUUsage { usage in
    print("📊 CPU usage: \(usage.cpuUsage)%")
    print("📊 CPU temperature: \(usage.temperature)°C")
}
```

### Performance Optimization

```swift
func optimizePerformance(for condition: PerformanceCondition)
```

Optimizes performance for a specific condition.

**Parameters:**
- `condition`: The performance condition

**Example:**
```swift
performanceManager.optimizePerformance(for: .lowMemory) { result in
    switch result {
    case .success:
        print("✅ Performance optimized for low memory")
    case .failure(let error):
        print("❌ Performance optimization failed: \(error)")
    }
}
```

## MetricsCollector

Collects and manages application metrics.

### Initialization

```swift
let metricsCollector = MetricsCollector()
```

### Configuration

```swift
func configure(_ configuration: MetricsConfiguration)
```

Configures the metrics collector.

**Parameters:**
- `configuration`: The metrics configuration object

**Example:**
```swift
let metricsConfig = MetricsConfiguration()
metricsConfig.enableMetricsCollection = true
metricsConfig.enableRealTimeMetrics = true
metricsConfig.enableHistoricalMetrics = true
metricsConfig.metricsRetentionPeriod = 30 // days

metricsCollector.configure(metricsConfig)
```

### Metrics Collection

```swift
func collectMetric(_ metric: Metric)
```

Collects a metric.

**Parameters:**
- `metric`: The metric to collect

**Example:**
```swift
let metric = Metric(
    name: "message_send_time",
    value: 150.0,
    unit: "ms",
    tags: ["room_id": "room_123"]
)

metricsCollector.collectMetric(metric)
```

```swift
func collectCounter(_ name: String, value: Int, tags: [String: String]? = nil)
```

Collects a counter metric.

**Parameters:**
- `name`: The counter name
- `value`: The counter value
- `tags`: Optional tags

**Example:**
```swift
metricsCollector.collectCounter("messages_sent", value: 1, tags: ["room_id": "room_123"])
```

```swift
func collectGauge(_ name: String, value: Double, tags: [String: String]? = nil)
```

Collects a gauge metric.

**Parameters:**
- `name`: The gauge name
- `value`: The gauge value
- `tags`: Optional tags

**Example:**
```swift
metricsCollector.collectGauge("active_users", value: 25.0, tags: ["room_id": "room_123"])
```

```swift
func collectHistogram(_ name: String, value: Double, tags: [String: String]? = nil)
```

Collects a histogram metric.

**Parameters:**
- `name`: The histogram name
- `value`: The histogram value
- `tags`: Optional tags

**Example:**
```swift
metricsCollector.collectHistogram("response_time", value: 150.0, tags: ["endpoint": "/api/messages"])
```

### Metrics Retrieval

```swift
func getMetrics(for name: String, timeRange: TimeRange, completion: @escaping ([Metric]) -> Void)
```

Gets metrics for a specific name and time range.

**Parameters:**
- `name`: The metric name
- `timeRange`: The time range
- `completion`: Completion handler called with the metrics

**Example:**
```swift
let timeRange = TimeRange(start: Date().addingTimeInterval(-3600), end: Date())
metricsCollector.getMetrics(for: "message_send_time", timeRange: timeRange) { metrics in
    print("📊 Found \(metrics.count) metrics")
    for metric in metrics {
        print("📊 \(metric.name): \(metric.value) \(metric.unit)")
    }
}
```

```swift
func getAggregatedMetrics(for name: String, aggregation: AggregationType, timeRange: TimeRange, completion: @escaping (AggregatedMetric) -> Void)
```

Gets aggregated metrics.

**Parameters:**
- `name`: The metric name
- `aggregation`: The aggregation type
- `timeRange`: The time range
- `completion`: Completion handler called with the aggregated metric

**Example:**
```swift
metricsCollector.getAggregatedMetrics(
    for: "message_send_time",
    aggregation: .average,
    timeRange: timeRange
) { aggregatedMetric in
    print("📊 Average message send time: \(aggregatedMetric.value) \(aggregatedMetric.unit)")
}
```

## EventTracker

Tracks application events and user interactions.

### Initialization

```swift
let eventTracker = EventTracker()
```

### Configuration

```swift
func configure(_ configuration: EventTrackingConfiguration)
```

Configures the event tracker.

**Parameters:**
- `configuration`: The event tracking configuration object

**Example:**
```swift
let eventConfig = EventTrackingConfiguration()
eventConfig.enableEventTracking = true
eventConfig.enableUserInteractionTracking = true
eventConfig.enableErrorTracking = true
eventConfig.enableCrashTracking = true

eventTracker.configure(eventConfig)
```

### Event Tracking

```swift
func trackEvent(_ event: TrackingEvent)
```

Tracks an event.

**Parameters:**
- `event`: The event to track

**Example:**
```swift
let event = TrackingEvent(
    name: "button_click",
    category: "user_interaction",
    parameters: [
        "button_id": "send_message",
        "screen": "chat_screen"
    ]
)

eventTracker.trackEvent(event)
```

```swift
func trackUserInteraction(_ interaction: UserInteraction)
```

Tracks a user interaction.

**Parameters:**
- `interaction`: The user interaction to track

**Example:**
```swift
let interaction = UserInteraction(
    type: .tap,
    element: "send_button",
    screen: "chat_screen",
    timestamp: Date()
)

eventTracker.trackUserInteraction(interaction)
```

```swift
func trackError(_ error: Error, context: [String: Any]? = nil)
```

Tracks an error.

**Parameters:**
- `error`: The error to track
- `context`: Optional error context

**Example:**
```swift
eventTracker.trackError(error, context: [
    "screen": "chat_screen",
    "action": "send_message"
])
```

```swift
func trackCrash(_ crash: CrashReport)
```

Tracks a crash.

**Parameters:**
- `crash`: The crash report to track

**Example:**
```swift
let crash = CrashReport(
    type: "NSException",
    message: "Unexpectedly found nil",
    stackTrace: "Stack trace here",
    timestamp: Date()
)

eventTracker.trackCrash(crash)
```

## HealthMonitor

Monitors application health and system status.

### Initialization

```swift
let healthMonitor = HealthMonitor()
```

### Configuration

```swift
func configure(_ configuration: HealthMonitoringConfiguration)
```

Configures the health monitor.

**Parameters:**
- `configuration`: The health monitoring configuration object

**Example:**
```swift
let healthConfig = HealthMonitoringConfiguration()
healthConfig.enableSystemHealthMonitoring = true
healthConfig.enableNetworkHealthMonitoring = true
healthConfig.enableBatteryHealthMonitoring = true
healthConfig.enableStorageHealthMonitoring = true

healthMonitor.configure(healthConfig)
```

### Health Monitoring

```swift
func startHealthMonitoring()
```

Starts health monitoring.

**Example:**
```swift
healthMonitor.startHealthMonitoring()
```

```swift
func stopHealthMonitoring()
```

Stops health monitoring.

**Example:**
```swift
healthMonitor.stopHealthMonitoring()
```

```swift
func getSystemHealth(_ completion: @escaping (SystemHealth) -> Void)
```

Gets system health information.

**Parameters:**
- `completion`: Completion handler called with system health data

**Example:**
```swift
healthMonitor.getSystemHealth { health in
    print("📊 System health: \(health.status)")
    print("📊 Memory usage: \(health.memoryUsage)%")
    print("📊 CPU usage: \(health.cpuUsage)%")
    print("📊 Battery level: \(health.batteryLevel)%")
    print("📊 Storage usage: \(health.storageUsage)%")
}
```

```swift
func getNetworkHealth(_ completion: @escaping (NetworkHealth) -> Void)
```

Gets network health information.

**Parameters:**
- `completion`: Completion handler called with network health data

**Example:**
```swift
healthMonitor.getNetworkHealth { health in
    print("📊 Network status: \(health.status)")
    print("📊 Connection type: \(health.connectionType)")
    print("📊 Signal strength: \(health.signalStrength)")
    print("📊 Latency: \(health.latency)ms")
}
```

```swift
func onHealthAlert(_ handler: @escaping (HealthAlert) -> Void)
```

Sets up a handler for health alerts.

**Parameters:**
- `handler`: Closure called when a health alert is triggered

**Example:**
```swift
healthMonitor.onHealthAlert { alert in
    switch alert.type {
    case .lowMemory:
        print("⚠️ Low memory alert")
    case .highCPU:
        print("⚠️ High CPU usage alert")
    case .lowBattery:
        print("⚠️ Low battery alert")
    case .networkIssue:
        print("⚠️ Network issue alert")
    case .storageFull:
        print("⚠️ Storage full alert")
    }
}
```

## MonitoringError

Represents monitoring errors.

### Error Types

```swift
enum MonitoringError: Error {
    case configurationFailed(String)
    case dataCollectionFailed(String)
    case metricsProcessingFailed(String)
    case analyticsError(String)
    case performanceError(String)
    case healthMonitoringError(String)
    case networkError(String)
    case storageError(String)
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
monitoringManager.onError { error in
    switch error {
    case .configurationFailed(let reason):
        print("❌ Configuration failed: \(reason)")
    case .dataCollectionFailed(let reason):
        print("❌ Data collection failed: \(reason)")
    case .metricsProcessingFailed(let reason):
        print("❌ Metrics processing failed: \(reason)")
    case .analyticsError(let message):
        print("❌ Analytics error: \(message)")
    case .performanceError(let message):
        print("❌ Performance error: \(message)")
    case .healthMonitoringError(let message):
        print("❌ Health monitoring error: \(message)")
    case .networkError(let message):
        print("❌ Network error: \(message)")
    case .storageError(let message):
        print("❌ Storage error: \(message)")
    }
}
```

## Complete Example

```swift
import RealTimeCommunication

class MonitoringManager: ObservableObject {
    private let monitoringManager = MonitoringManager()
    private let analyticsManager = AnalyticsManager()
    private let performanceManager = PerformanceManager()
    private let metricsCollector = MetricsCollector()
    private let eventTracker = EventTracker()
    private let healthMonitor = HealthMonitor()
    
    @Published var systemHealth: SystemHealth?
    @Published var networkHealth: NetworkHealth?
    @Published var lastHealthAlert: HealthAlert?
    
    init() {
        setupMonitoring()
    }
    
    private func setupMonitoring() {
        let config = MonitoringConfiguration()
        config.enableAnalytics = true
        config.enablePerformanceMonitoring = true
        config.enableHealthMonitoring = true
        config.enableMetricsCollection = true
        
        monitoringManager.configure(config)
        
        // Setup analytics
        let analyticsConfig = AnalyticsConfiguration()
        analyticsConfig.enableUserTracking = true
        analyticsConfig.enableEventTracking = true
        analyticsConfig.enableSessionTracking = true
        analyticsConfig.enableCrashReporting = true
        
        analyticsManager.configure(analyticsConfig)
        
        // Setup performance monitoring
        let performanceConfig = PerformanceConfiguration()
        performanceConfig.enableNetworkMonitoring = true
        performanceConfig.enableMemoryMonitoring = true
        performanceConfig.enableCPUMonitoring = true
        performanceConfig.enableBatteryMonitoring = true
        
        performanceManager.configure(performanceConfig)
        
        // Setup metrics collection
        let metricsConfig = MetricsConfiguration()
        metricsConfig.enableMetricsCollection = true
        metricsConfig.enableRealTimeMetrics = true
        metricsConfig.enableHistoricalMetrics = true
        metricsConfig.metricsRetentionPeriod = 30
        
        metricsCollector.configure(metricsConfig)
        
        // Setup event tracking
        let eventConfig = EventTrackingConfiguration()
        eventConfig.enableEventTracking = true
        eventConfig.enableUserInteractionTracking = true
        eventConfig.enableErrorTracking = true
        eventConfig.enableCrashTracking = true
        
        eventTracker.configure(eventConfig)
        
        // Setup health monitoring
        let healthConfig = HealthMonitoringConfiguration()
        healthConfig.enableSystemHealthMonitoring = true
        healthConfig.enableNetworkHealthMonitoring = true
        healthConfig.enableBatteryHealthMonitoring = true
        healthConfig.enableStorageHealthMonitoring = true
        
        healthMonitor.configure(healthConfig)
        
        // Start monitoring
        startMonitoring()
    }
    
    private func startMonitoring() {
        // Start health monitoring
        healthMonitor.startHealthMonitoring()
        
        // Setup health alerts
        healthMonitor.onHealthAlert { [weak self] alert in
            DispatchQueue.main.async {
                self?.lastHealthAlert = alert
            }
        }
        
        // Start performance monitoring
        startPerformanceMonitoring()
    }
    
    private func startPerformanceMonitoring() {
        // Monitor network performance
        performanceManager.monitorNetworkPerformance { [weak self] performance in
            DispatchQueue.main.async {
                // Update UI with network performance data
                print("📊 Network latency: \(performance.latency)ms")
            }
        }
        
        // Monitor memory usage
        performanceManager.monitorMemoryUsage { [weak self] usage in
            DispatchQueue.main.async {
                // Update UI with memory usage data
                print("📊 Memory used: \(usage.usedMemory) MB")
            }
        }
    }
    
    func trackUserAction(_ action: String, parameters: [String: Any]? = nil) {
        analyticsManager.trackUserAction(action, parameters: parameters)
        
        // Also track as event
        let event = TrackingEvent(
            name: action,
            category: "user_interaction",
            parameters: parameters ?? [:]
        )
        eventTracker.trackEvent(event)
    }
    
    func trackScreenView(_ screenName: String, parameters: [String: Any]? = nil) {
        analyticsManager.trackScreenView(screenName, parameters: parameters)
    }
    
    func collectMetric(_ name: String, value: Double, unit: String, tags: [String: String]? = nil) {
        let metric = Metric(
            name: name,
            value: value,
            unit: unit,
            tags: tags
        )
        metricsCollector.collectMetric(metric)
    }
    
    func getSystemHealth() {
        healthMonitor.getSystemHealth { [weak self] health in
            DispatchQueue.main.async {
                self?.systemHealth = health
            }
        }
    }
    
    func getNetworkHealth() {
        healthMonitor.getNetworkHealth { [weak self] health in
            DispatchQueue.main.async {
                self?.networkHealth = health
            }
        }
    }
    
    func startPerformanceTrace(_ name: String) -> PerformanceTrace {
        return performanceManager.startTrace(name)
    }
}

struct MonitoringView: View {
    @StateObject private var monitoringManager = MonitoringManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // System Health
                if let systemHealth = monitoringManager.systemHealth {
                    VStack(alignment: .leading) {
                        Text("System Health")
                            .font(.headline)
                        
                        HStack {
                            Text("Status:")
                            Text(systemHealth.status.rawValue)
                                .foregroundColor(systemHealth.status == .healthy ? .green : .red)
                        }
                        
                        HStack {
                            Text("Memory:")
                            Text("\(systemHealth.memoryUsage)%")
                        }
                        
                        HStack {
                            Text("CPU:")
                            Text("\(systemHealth.cpuUsage)%")
                        }
                        
                        HStack {
                            Text("Battery:")
                            Text("\(systemHealth.batteryLevel)%")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Network Health
                if let networkHealth = monitoringManager.networkHealth {
                    VStack(alignment: .leading) {
                        Text("Network Health")
                            .font(.headline)
                        
                        HStack {
                            Text("Status:")
                            Text(networkHealth.status.rawValue)
                                .foregroundColor(networkHealth.status == .connected ? .green : .red)
                        }
                        
                        HStack {
                            Text("Type:")
                            Text(networkHealth.connectionType.rawValue)
                        }
                        
                        HStack {
                            Text("Latency:")
                            Text("\(networkHealth.latency)ms")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Health Alert
                if let alert = monitoringManager.lastHealthAlert {
                    VStack(alignment: .leading) {
                        Text("Health Alert")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(alert.type.rawValue)
                            .font(.caption)
                        
                        Text(alert.message)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Actions
                VStack(spacing: 10) {
                    Button("Track User Action") {
                        monitoringManager.trackUserAction("button_click", parameters: [
                            "button_id": "monitor_button",
                            "screen": "monitoring_screen"
                        ])
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Collect Metric") {
                        monitoringManager.collectMetric(
                            "app_launch_time",
                            value: 1.5,
                            unit: "seconds",
                            tags: ["version": "2.1.0"]
                        )
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Get System Health") {
                        monitoringManager.getSystemHealth()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Get Network Health") {
                        monitoringManager.getNetworkHealth()
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Monitoring")
        }
    }
}

extension SystemHealthStatus: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: String) {
        switch rawValue {
        case "healthy": self = .healthy
        case "warning": self = .warning
        case "critical": self = .critical
        default: return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .healthy: return "healthy"
        case .warning: return "warning"
        case .critical: return "critical"
        }
    }
}

extension NetworkStatus: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: String) {
        switch rawValue {
        case "connected": self = .connected
        case "disconnected": self = .disconnected
        case "poor": self = .poor
        default: return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .connected: return "connected"
        case .disconnected: return "disconnected"
        case .poor: return "poor"
        }
    }
}
```

This comprehensive API documentation covers all aspects of the Monitoring module in the iOS Real-Time Communication Framework. For more examples and advanced usage, refer to the Monitoring Guide and other documentation.
