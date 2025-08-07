# Voice & Video Guide

## Overview

The Voice & Video module provides comprehensive WebRTC-based voice and video calling capabilities for iOS applications. This guide covers everything you need to know about implementing high-quality voice and video communication in your iOS app.

## Table of Contents

- [Getting Started](#getting-started)
- [Voice Calls](#voice-calls)
- [Video Calls](#video-calls)
- [Call Management](#call-management)
- [Media Handling](#media-handling)
- [Quality Control](#quality-control)
- [Screen Sharing](#screen-sharing)
- [Recording](#recording)
- [Security](#security)
- [Best Practices](#best-practices)

## Getting Started

### Prerequisites

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+
- WebRTC server (TURN/STUN)
- Camera and microphone permissions

### Installation

Add the framework to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Real-Time-Communication-Framework.git", from: "2.1.0")
]
```

### Basic Setup

```swift
import RealTimeCommunication

// Initialize voice and video manager
let voiceVideoManager = VoiceVideoManager()

// Configure voice and video
let config = VoiceVideoConfiguration()
config.enableVoiceCalls = true
config.enableVideoCalls = true
config.enableScreenSharing = true
config.enableRecording = true

// Setup voice and video
voiceVideoManager.configure(config)
```

## Voice Calls

### Voice Call Setup

```swift
// Initialize voice call manager
let voiceCallManager = WebRTCVoiceCall()

// Configure voice call
let voiceConfig = VoiceCallConfiguration()
voiceConfig.enableEchoCancellation = true
voiceConfig.enableNoiseSuppression = true
voiceConfig.enableAutomaticGainControl = true
voiceConfig.audioCodec = .opus
voiceConfig.sampleRate = 48000
voiceConfig.channels = 1

voiceCallManager.configure(voiceConfig)
```

### Starting Voice Calls

```swift
// Start voice call
voiceCallManager.startCall(with: "user_456") { result in
    switch result {
    case .success(let call):
        print("✅ Voice call started")
        print("Call ID: \(call.callId)")
        print("Status: \(call.status)")
    case .failure(let error):
        print("❌ Voice call failed: \(error)")
    }
}

// Answer incoming call
voiceCallManager.answerCall(callId: "call_123") { result in
    switch result {
    case .success(let call):
        print("✅ Call answered")
    case .failure(let error):
        print("❌ Answer call failed: \(error)")
    }
}

// End call
voiceCallManager.endCall(callId: "call_123") { result in
    switch result {
    case .success:
        print("✅ Call ended")
    case .failure(let error):
        print("❌ End call failed: \(error)")
    }
}
```

### Voice Call Events

```swift
// Handle call state changes
voiceCallManager.onCallStateChanged { state in
    switch state {
    case .connecting:
        print("🔄 Connecting voice call...")
    case .connected:
        print("✅ Voice call connected")
    case .disconnected:
        print("❌ Voice call disconnected")
    case .failed(let error):
        print("❌ Voice call failed: \(error)")
    case .ended:
        print("📞 Voice call ended")
    }
}

// Handle incoming calls
voiceCallManager.onIncomingCall { call in
    print("📞 Incoming call from: \(call.callerId)")
    print("Call ID: \(call.callId)")
    
    // Show incoming call UI
    self.showIncomingCallUI(call)
}

// Handle call quality
voiceCallManager.onCallQualityChanged { quality in
    print("📊 Call quality: \(quality.level)")
    print("Packet loss: \(quality.packetLoss)%")
    print("Latency: \(quality.latency)ms")
}
```

## Video Calls

### Video Call Setup

```swift
// Initialize video call manager
let videoCallManager = WebRTCVideoCall()

// Configure video call
let videoConfig = VideoCallConfiguration()
videoConfig.enableVideo = true
videoConfig.enableAudio = true
videoConfig.videoCodec = .h264
videoConfig.resolution = .hd720p
videoConfig.frameRate = 30
videoConfig.bitrate = 1000000 // 1 Mbps

videoCallManager.configure(videoConfig)
```

### Starting Video Calls

```swift
// Start video call
videoCallManager.startVideoCall(with: "user_456") { result in
    switch result {
    case .success(let call):
        print("✅ Video call started")
        print("Call ID: \(call.callId)")
        print("Status: \(call.status)")
    case .failure(let error):
        print("❌ Video call failed: \(error)")
    }
}

// Answer incoming video call
videoCallManager.answerVideoCall(callId: "call_123") { result in
    switch result {
    case .success(let call):
        print("✅ Video call answered")
    case .failure(let error):
        print("❌ Answer video call failed: \(error)")
    }
}

// End video call
videoCallManager.endVideoCall(callId: "call_123") { result in
    switch result {
    case .success:
        print("✅ Video call ended")
    case .failure(let error):
        print("❌ End video call failed: \(error)")
    }
}
```

### Video Call Events

```swift
// Handle video call state changes
videoCallManager.onVideoCallStateChanged { state in
    switch state {
    case .connecting:
        print("🔄 Connecting video call...")
    case .connected:
        print("✅ Video call connected")
    case .disconnected:
        print("❌ Video call disconnected")
    case .failed(let error):
        print("❌ Video call failed: \(error)")
    case .ended:
        print("📹 Video call ended")
    }
}

// Handle video stream
videoCallManager.onLocalVideoStream { stream in
    print("📹 Local video stream available")
    // Display local video
    self.displayLocalVideo(stream)
}

videoCallManager.onRemoteVideoStream { stream in
    print("📹 Remote video stream available")
    // Display remote video
    self.displayRemoteVideo(stream)
}
```

## Call Management

### Call Session Management

```swift
// Initialize call session manager
let callSessionManager = CallSessionManager()

// Configure call session
let sessionConfig = CallSessionConfiguration()
sessionConfig.enableCallHistory = true
sessionConfig.enableCallRecording = true
sessionConfig.enableCallAnalytics = true
sessionConfig.maxCallDuration = 3600 // 1 hour

callSessionManager.configure(sessionConfig)

// Create call session
callSessionManager.createSession(callType: .video, participants: ["user1", "user2"]) { result in
    switch result {
    case .success(let session):
        print("✅ Call session created: \(session.sessionId)")
    case .failure(let error):
        print("❌ Session creation failed: \(error)")
    }
}

// Join call session
callSessionManager.joinSession(sessionId: "session_123") { result in
    switch result {
    case .success(let session):
        print("✅ Joined call session")
    case .failure(let error):
        print("❌ Join session failed: \(error)")
    }
}

// Leave call session
callSessionManager.leaveSession(sessionId: "session_123") { result in
    switch result {
    case .success:
        print("✅ Left call session")
    case .failure(let error):
        print("❌ Leave session failed: \(error)")
    }
}
```

### Call Participants

```swift
// Handle participant events
callSessionManager.onParticipantJoined { participant in
    print("👤 Participant joined: \(participant.userId)")
    print("Role: \(participant.role)")
    print("Permissions: \(participant.permissions)")
}

callSessionManager.onParticipantLeft { participant in
    print("👋 Participant left: \(participant.userId)")
}

callSessionManager.onParticipantMuted { participant in
    print("🔇 Participant muted: \(participant.userId)")
}

callSessionManager.onParticipantUnmuted { participant in
    print("🔊 Participant unmuted: \(participant.userId)")
}
```

## Media Handling

### Audio Management

```swift
// Audio device management
let audioManager = AudioDeviceManager()

// Get available audio devices
audioManager.getAvailableDevices { devices in
    for device in devices {
        print("🎤 Audio device: \(device.name)")
        print("Type: \(device.type)")
        print("Default: \(device.isDefault)")
    }
}

// Set audio device
audioManager.setAudioDevice(deviceId: "device_123") { result in
    switch result {
    case .success:
        print("✅ Audio device set")
    case .failure(let error):
        print("❌ Set audio device failed: \(error)")
    }
}

// Audio level monitoring
audioManager.onAudioLevelChanged { level in
    print("📊 Audio level: \(level) dB")
}
```

### Video Management

```swift
// Video device management
let videoManager = VideoDeviceManager()

// Get available video devices
videoManager.getAvailableDevices { devices in
    for device in devices {
        print("📹 Video device: \(device.name)")
        print("Position: \(device.position)")
        print("Default: \(device.isDefault)")
    }
}

// Set video device
videoManager.setVideoDevice(deviceId: "device_456") { result in
    switch result {
    case .success:
        print("✅ Video device set")
    case .failure(let error):
        print("❌ Set video device failed: \(error)")
    }
}

// Camera control
videoManager.enableCamera(true) { result in
    switch result {
    case .success:
        print("✅ Camera enabled")
    case .failure(let error):
        print("❌ Enable camera failed: \(error)")
    }
}

videoManager.switchCamera { result in
    switch result {
    case .success:
        print("✅ Camera switched")
    case .failure(let error):
        print("❌ Switch camera failed: \(error)")
    }
}
```

### Media Quality Control

```swift
// Quality control manager
let qualityManager = MediaQualityManager()

// Configure quality settings
let qualityConfig = QualityConfiguration()
qualityConfig.enableAdaptiveBitrate = true
qualityConfig.enableAdaptiveResolution = true
qualityConfig.enableAdaptiveFrameRate = true
qualityConfig.targetBitrate = 1000000 // 1 Mbps
qualityConfig.maxBitrate = 2000000 // 2 Mbps
qualityConfig.minBitrate = 500000 // 500 Kbps

qualityManager.configure(qualityConfig)

// Monitor quality metrics
qualityManager.onQualityMetricsChanged { metrics in
    print("📊 Video bitrate: \(metrics.videoBitrate) bps")
    print("📊 Audio bitrate: \(metrics.audioBitrate) bps")
    print("📊 Frame rate: \(metrics.frameRate) fps")
    print("📊 Resolution: \(metrics.resolution)")
    print("📊 Packet loss: \(metrics.packetLoss)%")
    print("📊 Latency: \(metrics.latency)ms")
}
```

## Quality Control

### Bandwidth Management

```swift
// Bandwidth manager
let bandwidthManager = BandwidthManager()

// Configure bandwidth
let bandwidthConfig = BandwidthConfiguration()
bandwidthConfig.enableAdaptiveBandwidth = true
bandwidthConfig.initialBandwidth = 1000000 // 1 Mbps
bandwidthConfig.maxBandwidth = 5000000 // 5 Mbps
bandwidthConfig.minBandwidth = 500000 // 500 Kbps

bandwidthManager.configure(bandwidthConfig)

// Monitor bandwidth
bandwidthManager.onBandwidthChanged { bandwidth in
    print("📊 Available bandwidth: \(bandwidth) bps")
}
```

### Network Adaptation

```swift
// Network adaptation manager
let networkManager = NetworkAdaptationManager()

// Configure network adaptation
let networkConfig = NetworkAdaptationConfiguration()
networkConfig.enableNetworkAdaptation = true
networkConfig.adaptationThreshold = 0.1 // 10% packet loss
networkConfig.adaptationInterval = 5 // 5 seconds

networkManager.configure(networkConfig)

// Handle network changes
networkManager.onNetworkChanged { network in
    print("🌐 Network type: \(network.type)")
    print("🌐 Network quality: \(network.quality)")
    print("🌐 Available bandwidth: \(network.bandwidth) bps")
}
```

## Screen Sharing

### Screen Sharing Setup

```swift
// Screen sharing manager
let screenSharingManager = ScreenSharingManager()

// Configure screen sharing
let screenConfig = ScreenSharingConfiguration()
screenConfig.enableScreenSharing = true
screenConfig.enableAudioSharing = true
screenConfig.resolution = .hd720p
screenConfig.frameRate = 15

screenSharingManager.configure(screenConfig)

// Start screen sharing
screenSharingManager.startScreenSharing { result in
    switch result {
    case .success(let stream):
        print("✅ Screen sharing started")
    case .failure(let error):
        print("❌ Screen sharing failed: \(error)")
    }
}

// Stop screen sharing
screenSharingManager.stopScreenSharing { result in
    switch result {
    case .success:
        print("✅ Screen sharing stopped")
    case .failure(let error):
        print("❌ Stop screen sharing failed: \(error)")
    }
}
```

### Screen Sharing Events

```swift
// Handle screen sharing events
screenSharingManager.onScreenSharingStarted { stream in
    print("📺 Screen sharing started")
}

screenSharingManager.onScreenSharingStopped {
    print("📺 Screen sharing stopped")
}

screenSharingManager.onScreenSharingError { error in
    print("❌ Screen sharing error: \(error)")
}
```

## Recording

### Call Recording

```swift
// Call recording manager
let recordingManager = CallRecordingManager()

// Configure recording
let recordingConfig = RecordingConfiguration()
recordingConfig.enableRecording = true
recordingConfig.recordingFormat = .mp4
recordingConfig.videoQuality = .high
recordingConfig.audioQuality = .high
recordingConfig.includeAudio = true
recordingConfig.includeVideo = true

recordingManager.configure(recordingConfig)

// Start recording
recordingManager.startRecording(callId: "call_123") { result in
    switch result {
    case .success(let recording):
        print("✅ Recording started")
        print("Recording ID: \(recording.recordingId)")
    case .failure(let error):
        print("❌ Start recording failed: \(error)")
    }
}

// Stop recording
recordingManager.stopRecording(recordingId: "recording_456") { result in
    switch result {
    case .success(let recording):
        print("✅ Recording stopped")
        print("File path: \(recording.filePath)")
        print("Duration: \(recording.duration) seconds")
    case .failure(let error):
        print("❌ Stop recording failed: \(error)")
    }
}
```

### Recording Management

```swift
// Get recording list
recordingManager.getRecordings { result in
    switch result {
    case .success(let recordings):
        for recording in recordings {
            print("📹 Recording: \(recording.recordingId)")
            print("Date: \(recording.date)")
            print("Duration: \(recording.duration) seconds")
            print("Size: \(recording.fileSize) bytes")
        }
    case .failure(let error):
        print("❌ Get recordings failed: \(error)")
    }
}

// Delete recording
recordingManager.deleteRecording(recordingId: "recording_456") { result in
    switch result {
    case .success:
        print("✅ Recording deleted")
    case .failure(let error):
        print("❌ Delete recording failed: \(error)")
    }
}
```

## Security

### Encryption

```swift
// Encryption manager
let encryptionManager = CallEncryptionManager()

// Configure encryption
let encryptionConfig = EncryptionConfiguration()
encryptionConfig.enableEndToEndEncryption = true
encryptionConfig.encryptionAlgorithm = .aes256
encryptionConfig.enableKeyRotation = true
encryptionConfig.keyRotationInterval = 3600 // 1 hour

encryptionManager.configure(encryptionConfig)

// Verify encryption
encryptionManager.verifyEncryption { result in
    switch result {
    case .success(let status):
        print("🔒 Encryption status: \(status)")
    case .failure(let error):
        print("❌ Encryption verification failed: \(error)")
    }
}
```

### Authentication

```swift
// Call authentication manager
let authManager = CallAuthenticationManager()

// Configure authentication
let authConfig = CallAuthenticationConfiguration()
authConfig.enableCallAuthentication = true
authConfig.requireAuthentication = true
authConfig.authenticationMethod = .token

authManager.configure(authConfig)

// Authenticate call
authManager.authenticateCall(callId: "call_123", token: "auth_token") { result in
    switch result {
    case .success:
        print("✅ Call authenticated")
    case .failure(let error):
        print("❌ Call authentication failed: \(error)")
    }
}
```

## Best Practices

### 1. Call Quality

- Monitor call quality metrics
- Implement adaptive bitrate
- Handle network changes gracefully
- Optimize for different network conditions

### 2. User Experience

- Provide clear call status indicators
- Handle call interruptions properly
- Implement proper error handling
- Provide call controls (mute, camera switch, etc.)

### 3. Performance

- Optimize media processing
- Handle memory efficiently
- Implement proper cleanup
- Monitor resource usage

### 4. Security

- Implement end-to-end encryption
- Authenticate all calls
- Validate media streams
- Protect user privacy

### 5. Testing

- Test on different devices
- Test various network conditions
- Test call scenarios
- Test security features

## Examples

### Complete Voice & Video Implementation

```swift
import RealTimeCommunication
import SwiftUI
import AVFoundation

class VoiceVideoManager: ObservableObject {
    private let voiceVideoManager = VoiceVideoManager()
    private let voiceCallManager = WebRTCVoiceCall()
    private let videoCallManager = WebRTCVideoCall()
    
    @Published var isInCall = false
    @Published var callType: CallType = .none
    @Published var callStatus: CallStatus = .idle
    @Published var isMuted = false
    @Published var isCameraEnabled = true
    @Published var callDuration: TimeInterval = 0
    
    private var callTimer: Timer?
    
    init() {
        setupVoiceVideo()
    }
    
    private func setupVoiceVideo() {
        let config = VoiceVideoConfiguration()
        config.enableVoiceCalls = true
        config.enableVideoCalls = true
        config.enableScreenSharing = true
        config.enableRecording = true
        
        voiceVideoManager.configure(config)
        
        // Configure voice calls
        let voiceConfig = VoiceCallConfiguration()
        voiceConfig.enableEchoCancellation = true
        voiceConfig.enableNoiseSuppression = true
        voiceConfig.enableAutomaticGainControl = true
        voiceConfig.audioCodec = .opus
        
        voiceCallManager.configure(voiceConfig)
        
        // Configure video calls
        let videoConfig = VideoCallConfiguration()
        videoConfig.enableVideo = true
        videoConfig.enableAudio = true
        videoConfig.videoCodec = .h264
        videoConfig.resolution = .hd720p
        videoConfig.frameRate = 30
        
        videoCallManager.configure(videoConfig)
        
        // Handle call events
        setupCallEventHandlers()
    }
    
    private func setupCallEventHandlers() {
        // Voice call events
        voiceCallManager.onCallStateChanged { [weak self] state in
            DispatchQueue.main.async {
                self?.handleCallStateChange(state)
            }
        }
        
        // Video call events
        videoCallManager.onVideoCallStateChanged { [weak self] state in
            DispatchQueue.main.async {
                self?.handleVideoCallStateChange(state)
            }
        }
        
        // Incoming calls
        voiceCallManager.onIncomingCall { [weak self] call in
            DispatchQueue.main.async {
                self?.handleIncomingCall(call)
            }
        }
        
        videoCallManager.onIncomingVideoCall { [weak self] call in
            DispatchQueue.main.async {
                self?.handleIncomingVideoCall(call)
            }
        }
    }
    
    func startVoiceCall(with userId: String) {
        voiceCallManager.startCall(with: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let call):
                    self?.isInCall = true
                    self?.callType = .voice
                    self?.callStatus = .connecting
                    self?.startCallTimer()
                    print("✅ Voice call started")
                case .failure(let error):
                    print("❌ Voice call failed: \(error)")
                }
            }
        }
    }
    
    func startVideoCall(with userId: String) {
        videoCallManager.startVideoCall(with: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let call):
                    self?.isInCall = true
                    self?.callType = .video
                    self?.callStatus = .connecting
                    self?.startCallTimer()
                    print("✅ Video call started")
                case .failure(let error):
                    print("❌ Video call failed: \(error)")
                }
            }
        }
    }
    
    func answerCall(callId: String) {
        switch callType {
        case .voice:
            voiceCallManager.answerCall(callId: callId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.callStatus = .connected
                        self?.startCallTimer()
                    case .failure(let error):
                        print("❌ Answer call failed: \(error)")
                    }
                }
            }
        case .video:
            videoCallManager.answerVideoCall(callId: callId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.callStatus = .connected
                        self?.startCallTimer()
                    case .failure(let error):
                        print("❌ Answer video call failed: \(error)")
                    }
                }
            }
        case .none:
            break
        }
    }
    
    func endCall() {
        switch callType {
        case .voice:
            voiceCallManager.endCall(callId: "current_call_id") { [weak self] result in
                DispatchQueue.main.async {
                    self?.endCallSession()
                }
            }
        case .video:
            videoCallManager.endVideoCall(callId: "current_call_id") { [weak self] result in
                DispatchQueue.main.async {
                    self?.endCallSession()
                }
            }
        case .none:
            break
        }
    }
    
    func toggleMute() {
        isMuted.toggle()
        
        switch callType {
        case .voice:
            voiceCallManager.setMuted(isMuted)
        case .video:
            videoCallManager.setMuted(isMuted)
        case .none:
            break
        }
    }
    
    func toggleCamera() {
        isCameraEnabled.toggle()
        
        if callType == .video {
            videoCallManager.setCameraEnabled(isCameraEnabled)
        }
    }
    
    private func handleCallStateChange(_ state: CallState) {
        switch state {
        case .connecting:
            callStatus = .connecting
        case .connected:
            callStatus = .connected
        case .disconnected:
            endCallSession()
        case .failed(let error):
            callStatus = .failed
            print("❌ Call failed: \(error)")
        case .ended:
            endCallSession()
        }
    }
    
    private func handleVideoCallStateChange(_ state: VideoCallState) {
        switch state {
        case .connecting:
            callStatus = .connecting
        case .connected:
            callStatus = .connected
        case .disconnected:
            endCallSession()
        case .failed(let error):
            callStatus = .failed
            print("❌ Video call failed: \(error)")
        case .ended:
            endCallSession()
        }
    }
    
    private func handleIncomingCall(_ call: VoiceCall) {
        // Show incoming call UI
        print("📞 Incoming voice call from: \(call.callerId)")
    }
    
    private func handleIncomingVideoCall(_ call: VideoCall) {
        // Show incoming video call UI
        print("📹 Incoming video call from: \(call.callerId)")
    }
    
    private func startCallTimer() {
        callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.callDuration += 1
            }
        }
    }
    
    private func endCallSession() {
        callTimer?.invalidate()
        callTimer = nil
        
        isInCall = false
        callType = .none
        callStatus = .idle
        callDuration = 0
        isMuted = false
        isCameraEnabled = true
    }
}

enum CallType {
    case none
    case voice
    case video
}

enum CallStatus {
    case idle
    case connecting
    case connected
    case failed
}

struct VoiceVideoCallView: View {
    @StateObject private var voiceVideoManager = VoiceVideoManager()
    @State private var selectedUserId = ""
    @State private var showingCallControls = false
    
    var body: some View {
        VStack {
            if voiceVideoManager.isInCall {
                // Call interface
                VStack {
                    // Call status
                    HStack {
                        Circle()
                            .fill(voiceVideoManager.callStatus == .connected ? Color.green : Color.orange)
                            .frame(width: 10, height: 10)
                        Text(voiceVideoManager.callStatus.rawValue.capitalized)
                        Spacer()
                        Text(formatDuration(voiceVideoManager.callDuration))
                    }
                    .padding()
                    
                    // Call type indicator
                    HStack {
                        Image(systemName: voiceVideoManager.callType == .voice ? "phone" : "video")
                        Text(voiceVideoManager.callType == .voice ? "Voice Call" : "Video Call")
                    }
                    .padding()
                    
                    // Call controls
                    HStack(spacing: 30) {
                        Button(action: {
                            voiceVideoManager.toggleMute()
                        }) {
                            Image(systemName: voiceVideoManager.isMuted ? "mic.slash.fill" : "mic.fill")
                                .font(.title)
                                .foregroundColor(voiceVideoManager.isMuted ? .red : .white)
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            voiceVideoManager.endCall()
                        }) {
                            Image(systemName: "phone.down.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        
                        if voiceVideoManager.callType == .video {
                            Button(action: {
                                voiceVideoManager.toggleCamera()
                            }) {
                                Image(systemName: voiceVideoManager.isCameraEnabled ? "video.fill" : "video.slash.fill")
                                    .font(.title)
                                    .foregroundColor(voiceVideoManager.isCameraEnabled ? .white : .red)
                                    .frame(width: 60, height: 60)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding()
                }
            } else {
                // Call initiation interface
                VStack(spacing: 20) {
                    Text("Voice & Video Calls")
                        .font(.largeTitle)
                        .padding()
                    
                    TextField("Enter user ID", text: $selectedUserId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    HStack(spacing: 20) {
                        Button("Voice Call") {
                            if !selectedUserId.isEmpty {
                                voiceVideoManager.startVoiceCall(with: selectedUserId)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedUserId.isEmpty)
                        
                        Button("Video Call") {
                            if !selectedUserId.isEmpty {
                                voiceVideoManager.startVideoCall(with: selectedUserId)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedUserId.isEmpty)
                    }
                }
            }
        }
        .padding()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension CallStatus: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: String) {
        switch rawValue {
        case "idle": self = .idle
        case "connecting": self = .connecting
        case "connected": self = .connected
        case "failed": self = .failed
        default: return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .idle: return "idle"
        case .connecting: return "connecting"
        case .connected: return "connected"
        case .failed: return "failed"
        }
    }
}
```

This comprehensive guide covers all aspects of voice and video implementation in the iOS Real-Time Communication Framework. For more advanced features and examples, refer to the API documentation and other guides.
