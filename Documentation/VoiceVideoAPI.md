# Voice & Video API

<!-- TOC START -->
## Table of Contents
- [Voice & Video API](#voice-video-api)
- [Overview](#overview)
- [Table of Contents](#table-of-contents)
- [VoiceVideoManager](#voicevideomanager)
  - [Initialization](#initialization)
  - [Configuration](#configuration)
  - [Service Management](#service-management)
- [VoiceVideoConfiguration](#voicevideoconfiguration)
  - [Properties](#properties)
  - [Example](#example)
- [WebRTCVoiceCall](#webrtcvoicecall)
  - [Initialization](#initialization)
  - [Configuration](#configuration)
  - [Call Management](#call-management)
  - [Call Events](#call-events)
- [WebRTCVideoCall](#webrtcvideocall)
  - [Initialization](#initialization)
  - [Configuration](#configuration)
  - [Call Management](#call-management)
  - [Video Events](#video-events)
- [CallSessionManager](#callsessionmanager)
  - [Initialization](#initialization)
  - [Configuration](#configuration)
  - [Session Management](#session-management)
  - [Participant Events](#participant-events)
- [MediaDeviceManager](#mediadevicemanager)
  - [Initialization](#initialization)
  - [Audio Management](#audio-management)
  - [Video Management](#video-management)
- [CallQualityManager](#callqualitymanager)
  - [Initialization](#initialization)
  - [Configuration](#configuration)
  - [Quality Monitoring](#quality-monitoring)
- [VoiceVideoError](#voicevideoerror)
  - [Error Types](#error-types)
  - [Properties](#properties)
  - [Example](#example)
- [Enums](#enums)
  - [CallType](#calltype)
  - [CallState](#callstate)
  - [VideoCallState](#videocallstate)
  - [AudioCodec](#audiocodec)
  - [VideoCodec](#videocodec)
  - [VideoResolution](#videoresolution)
  - [NetworkCondition](#networkcondition)
- [Complete Example](#complete-example)
<!-- TOC END -->


## Overview

The Voice & Video API provides comprehensive WebRTC-based voice and video calling capabilities for iOS applications. This document covers all public interfaces, classes, and methods available in the Voice & Video module.

## Table of Contents

- [VoiceVideoManager](#voicevideomanager)
- [VoiceVideoConfiguration](#voicevideoconfiguration)
- [WebRTCVoiceCall](#webrtcvoicecall)
- [WebRTCVideoCall](#webrtcvideocall)
- [CallSessionManager](#callsessionmanager)
- [MediaDeviceManager](#mediadevicemanager)
- [CallQualityManager](#callqualitymanager)
- [VoiceVideoError](#voicevideoerror)

## VoiceVideoManager

The main voice and video manager class that coordinates all voice and video services.

### Initialization

```swift
let voiceVideoManager = VoiceVideoManager()
```

### Configuration

```swift
func configure(_ configuration: VoiceVideoConfiguration)
```

Configures the voice and video manager with the specified configuration.

**Parameters:**
- `configuration`: The voice and video configuration object

**Example:**
```swift
let config = VoiceVideoConfiguration()
config.enableVoiceCalls = true
config.enableVideoCalls = true
config.enableScreenSharing = true
config.enableRecording = true

voiceVideoManager.configure(config)
```

### Service Management

```swift
func getVoiceCallManager() -> WebRTCVoiceCall
```

Gets the voice call manager.

**Returns:**
- The voice call manager instance

```swift
func getVideoCallManager() -> WebRTCVideoCall
```

Gets the video call manager.

**Returns:**
- The video call manager instance

```swift
func getCallSessionManager() -> CallSessionManager
```

Gets the call session manager.

**Returns:**
- The call session manager instance

```swift
func getMediaDeviceManager() -> MediaDeviceManager
```

Gets the media device manager.

**Returns:**
- The media device manager instance

```swift
func getCallQualityManager() -> CallQualityManager
```

Gets the call quality manager.

**Returns:**
- The call quality manager instance

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
let config = VoiceVideoConfiguration()
config.enableVoiceCalls = true
config.enableVideoCalls = true
config.enableScreenSharing = true
config.enableRecording = true
config.enableEchoCancellation = true
config.enableNoiseSuppression = true
config.enableAutomaticGainControl = true
config.audioCodec = .opus
config.videoCodec = .h264
config.resolution = .hd720p
config.frameRate = 30
config.bitrate = 1000000 // 1 Mbps
```

## WebRTCVoiceCall

Manages WebRTC voice call operations.

### Initialization

```swift
let voiceCallManager = WebRTCVoiceCall()
```

### Configuration

```swift
func configure(_ configuration: VoiceCallConfiguration)
```

Configures the voice call manager.

**Parameters:**
- `configuration`: The voice call configuration object

**Example:**
```swift
let voiceConfig = VoiceCallConfiguration()
voiceConfig.enableEchoCancellation = true
voiceConfig.enableNoiseSuppression = true
voiceConfig.enableAutomaticGainControl = true
voiceConfig.audioCodec = .opus
voiceConfig.sampleRate = 48000
voiceConfig.channels = 1

voiceCallManager.configure(voiceConfig)
```

### Call Management

```swift
func startCall(with userId: String, completion: @escaping (Result<VoiceCall, VoiceVideoError>) -> Void)
```

Starts a voice call with a user.

**Parameters:**
- `userId`: The user ID to call
- `completion`: Completion handler called with the call result

**Example:**
```swift
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
```

```swift
func answerCall(callId: String, completion: @escaping (Result<VoiceCall, VoiceVideoError>) -> Void)
```

Answers an incoming voice call.

**Parameters:**
- `callId`: The call ID to answer
- `completion`: Completion handler called with the answer result

**Example:**
```swift
voiceCallManager.answerCall(callId: "call_123") { result in
    switch result {
    case .success(let call):
        print("✅ Call answered")
    case .failure(let error):
        print("❌ Answer call failed: \(error)")
    }
}
```

```swift
func endCall(callId: String, completion: @escaping (Result<Void, VoiceVideoError>) -> Void)
```

Ends a voice call.

**Parameters:**
- `callId`: The call ID to end
- `completion`: Completion handler called with the end result

**Example:**
```swift
voiceCallManager.endCall(callId: "call_123") { result in
    switch result {
    case .success:
        print("✅ Call ended")
    case .failure(let error):
        print("❌ End call failed: \(error)")
    }
}
```

### Call Events

```swift
func onCallStateChanged(_ handler: @escaping (CallState) -> Void)
```

Sets up a handler for call state changes.

**Parameters:**
- `handler`: Closure called when call state changes

**Example:**
```swift
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
```

```swift
func onIncomingCall(_ handler: @escaping (VoiceCall) -> Void)
```

Sets up a handler for incoming calls.

**Parameters:**
- `handler`: Closure called when an incoming call is received

**Example:**
```swift
voiceCallManager.onIncomingCall { call in
    print("📞 Incoming call from: \(call.callerId)")
    print("Call ID: \(call.callId)")
    
    // Show incoming call UI
    self.showIncomingCallUI(call)
}
```

```swift
func onCallQualityChanged(_ handler: @escaping (CallQuality) -> Void)
```

Sets up a handler for call quality changes.

**Parameters:**
- `handler`: Closure called when call quality changes

**Example:**
```swift
voiceCallManager.onCallQualityChanged { quality in
    print("📊 Call quality: \(quality.level)")
    print("Packet loss: \(quality.packetLoss)%")
    print("Latency: \(quality.latency)ms")
}
```

## WebRTCVideoCall

Manages WebRTC video call operations.

### Initialization

```swift
let videoCallManager = WebRTCVideoCall()
```

### Configuration

```swift
func configure(_ configuration: VideoCallConfiguration)
```

Configures the video call manager.

**Parameters:**
- `configuration`: The video call configuration object

**Example:**
```swift
let videoConfig = VideoCallConfiguration()
videoConfig.enableVideo = true
videoConfig.enableAudio = true
videoConfig.videoCodec = .h264
videoConfig.resolution = .hd720p
videoConfig.frameRate = 30
videoConfig.bitrate = 1000000 // 1 Mbps

videoCallManager.configure(videoConfig)
```

### Call Management

```swift
func startVideoCall(with userId: String, completion: @escaping (Result<VideoCall, VoiceVideoError>) -> Void)
```

Starts a video call with a user.

**Parameters:**
- `userId`: The user ID to call
- `completion`: Completion handler called with the call result

**Example:**
```swift
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
```

```swift
func answerVideoCall(callId: String, completion: @escaping (Result<VideoCall, VoiceVideoError>) -> Void)
```

Answers an incoming video call.

**Parameters:**
- `callId`: The call ID to answer
- `completion`: Completion handler called with the answer result

**Example:**
```swift
videoCallManager.answerVideoCall(callId: "call_123") { result in
    switch result {
    case .success(let call):
        print("✅ Video call answered")
    case .failure(let error):
        print("❌ Answer video call failed: \(error)")
    }
}
```

```swift
func endVideoCall(callId: String, completion: @escaping (Result<Void, VoiceVideoError>) -> Void)
```

Ends a video call.

**Parameters:**
- `callId`: The call ID to end
- `completion`: Completion handler called with the end result

**Example:**
```swift
videoCallManager.endVideoCall(callId: "call_123") { result in
    switch result {
    case .success:
        print("✅ Video call ended")
    case .failure(let error):
        print("❌ End video call failed: \(error)")
    }
}
```

### Video Events

```swift
func onVideoCallStateChanged(_ handler: @escaping (VideoCallState) -> Void)
```

Sets up a handler for video call state changes.

**Parameters:**
- `handler`: Closure called when video call state changes

**Example:**
```swift
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
```

```swift
func onLocalVideoStream(_ handler: @escaping (VideoStream) -> Void)
```

Sets up a handler for local video stream.

**Parameters:**
- `handler`: Closure called when local video stream is available

**Example:**
```swift
videoCallManager.onLocalVideoStream { stream in
    print("📹 Local video stream available")
    // Display local video
    self.displayLocalVideo(stream)
}
```

```swift
func onRemoteVideoStream(_ handler: @escaping (VideoStream) -> Void)
```

Sets up a handler for remote video stream.

**Parameters:**
- `handler`: Closure called when remote video stream is available

**Example:**
```swift
videoCallManager.onRemoteVideoStream { stream in
    print("📹 Remote video stream available")
    // Display remote video
    self.displayRemoteVideo(stream)
}
```

## CallSessionManager

Manages call session operations.

### Initialization

```swift
let callSessionManager = CallSessionManager()
```

### Configuration

```swift
func configure(_ configuration: CallSessionConfiguration)
```

Configures the call session manager.

**Parameters:**
- `configuration`: The call session configuration object

**Example:**
```swift
let sessionConfig = CallSessionConfiguration()
sessionConfig.enableCallHistory = true
sessionConfig.enableCallRecording = true
sessionConfig.enableCallAnalytics = true
sessionConfig.maxCallDuration = 3600 // 1 hour

callSessionManager.configure(sessionConfig)
```

### Session Management

```swift
func createSession(callType: CallType, participants: [String], completion: @escaping (Result<CallSession, VoiceVideoError>) -> Void)
```

Creates a new call session.

**Parameters:**
- `callType`: The type of call (voice or video)
- `participants`: Array of participant user IDs
- `completion`: Completion handler called with the session result

**Example:**
```swift
callSessionManager.createSession(callType: .video, participants: ["user1", "user2"]) { result in
    switch result {
    case .success(let session):
        print("✅ Call session created: \(session.sessionId)")
    case .failure(let error):
        print("❌ Session creation failed: \(error)")
    }
}
```

```swift
func joinSession(sessionId: String, completion: @escaping (Result<CallSession, VoiceVideoError>) -> Void)
```

Joins an existing call session.

**Parameters:**
- `sessionId`: The session ID to join
- `completion`: Completion handler called with the join result

**Example:**
```swift
callSessionManager.joinSession(sessionId: "session_123") { result in
    switch result {
    case .success(let session):
        print("✅ Joined call session")
    case .failure(let error):
        print("❌ Join session failed: \(error)")
    }
}
```

```swift
func leaveSession(sessionId: String, completion: @escaping (Result<Void, VoiceVideoError>) -> Void)
```

Leaves a call session.

**Parameters:**
- `sessionId`: The session ID to leave
- `completion`: Completion handler called with the leave result

**Example:**
```swift
callSessionManager.leaveSession(sessionId: "session_123") { result in
    switch result {
    case .success:
        print("✅ Left call session")
    case .failure(let error):
        print("❌ Leave session failed: \(error)")
    }
}
```

### Participant Events

```swift
func onParticipantJoined(_ handler: @escaping (CallParticipant) -> Void)
```

Sets up a handler for participant join events.

**Parameters:**
- `handler`: Closure called when a participant joins

**Example:**
```swift
callSessionManager.onParticipantJoined { participant in
    print("👤 Participant joined: \(participant.userId)")
    print("Role: \(participant.role)")
    print("Permissions: \(participant.permissions)")
}
```

```swift
func onParticipantLeft(_ handler: @escaping (CallParticipant) -> Void)
```

Sets up a handler for participant leave events.

**Parameters:**
- `handler`: Closure called when a participant leaves

**Example:**
```swift
callSessionManager.onParticipantLeft { participant in
    print("👋 Participant left: \(participant.userId)")
}
```

```swift
func onParticipantMuted(_ handler: @escaping (CallParticipant) -> Void)
```

Sets up a handler for participant mute events.

**Parameters:**
- `handler`: Closure called when a participant is muted

**Example:**
```swift
callSessionManager.onParticipantMuted { participant in
    print("🔇 Participant muted: \(participant.userId)")
}
```

```swift
func onParticipantUnmuted(_ handler: @escaping (CallParticipant) -> Void)
```

Sets up a handler for participant unmute events.

**Parameters:**
- `handler`: Closure called when a participant is unmuted

**Example:**
```swift
callSessionManager.onParticipantUnmuted { participant in
    print("🔊 Participant unmuted: \(participant.userId)")
}
```

## MediaDeviceManager

Manages media device operations.

### Initialization

```swift
let mediaDeviceManager = MediaDeviceManager()
```

### Audio Management

```swift
func getAvailableAudioDevices(completion: @escaping ([AudioDevice]) -> Void)
```

Gets available audio devices.

**Parameters:**
- `completion`: Completion handler called with the audio devices

**Example:**
```swift
mediaDeviceManager.getAvailableAudioDevices { devices in
    for device in devices {
        print("🎤 Audio device: \(device.name)")
        print("Type: \(device.type)")
        print("Default: \(device.isDefault)")
    }
}
```

```swift
func setAudioDevice(_ deviceId: String, completion: @escaping (Result<Void, VoiceVideoError>) -> Void)
```

Sets the audio device.

**Parameters:**
- `deviceId`: The device ID to set
- `completion`: Completion handler called with the set result

**Example:**
```swift
mediaDeviceManager.setAudioDevice("device_123") { result in
    switch result {
    case .success:
        print("✅ Audio device set")
    case .failure(let error):
        print("❌ Set audio device failed: \(error)")
    }
}
```

```swift
func onAudioLevelChanged(_ handler: @escaping (Float) -> Void)
```

Sets up a handler for audio level changes.

**Parameters:**
- `handler`: Closure called when audio level changes

**Example:**
```swift
mediaDeviceManager.onAudioLevelChanged { level in
    print("📊 Audio level: \(level) dB")
}
```

### Video Management

```swift
func getAvailableVideoDevices(completion: @escaping ([VideoDevice]) -> Void)
```

Gets available video devices.

**Parameters:**
- `completion`: Completion handler called with the video devices

**Example:**
```swift
mediaDeviceManager.getAvailableVideoDevices { devices in
    for device in devices {
        print("📹 Video device: \(device.name)")
        print("Position: \(device.position)")
        print("Default: \(device.isDefault)")
    }
}
```

```swift
func setVideoDevice(_ deviceId: String, completion: @escaping (Result<Void, VoiceVideoError>) -> Void)
```

Sets the video device.

**Parameters:**
- `deviceId`: The device ID to set
- `completion`: Completion handler called with the set result

**Example:**
```swift
mediaDeviceManager.setVideoDevice("device_456") { result in
    switch result {
    case .success:
        print("✅ Video device set")
    case .failure(let error):
        print("❌ Set video device failed: \(error)")
    }
}
```

```swift
func enableCamera(_ enabled: Bool, completion: @escaping (Result<Void, VoiceVideoError>) -> Void)
```

Enables or disables the camera.

**Parameters:**
- `enabled`: Whether to enable the camera
- `completion`: Completion handler called with the enable result

**Example:**
```swift
mediaDeviceManager.enableCamera(true) { result in
    switch result {
    case .success:
        print("✅ Camera enabled")
    case .failure(let error):
        print("❌ Enable camera failed: \(error)")
    }
}
```

```swift
func switchCamera(completion: @escaping (Result<Void, VoiceVideoError>) -> Void)
```

Switches between front and back cameras.

**Parameters:**
- `completion`: Completion handler called with the switch result

**Example:**
```swift
mediaDeviceManager.switchCamera { result in
    switch result {
    case .success:
        print("✅ Camera switched")
    case .failure(let error):
        print("❌ Switch camera failed: \(error)")
    }
}
```

## CallQualityManager

Manages call quality monitoring and optimization.

### Initialization

```swift
let callQualityManager = CallQualityManager()
```

### Configuration

```swift
func configure(_ configuration: QualityConfiguration)
```

Configures the call quality manager.

**Parameters:**
- `configuration`: The quality configuration object

**Example:**
```swift
let qualityConfig = QualityConfiguration()
qualityConfig.enableAdaptiveBitrate = true
qualityConfig.enableAdaptiveResolution = true
qualityConfig.enableAdaptiveFrameRate = true
qualityConfig.targetBitrate = 1000000 // 1 Mbps
qualityConfig.maxBitrate = 2000000 // 2 Mbps
qualityConfig.minBitrate = 500000 // 500 Kbps

callQualityManager.configure(qualityConfig)
```

### Quality Monitoring

```swift
func onQualityMetricsChanged(_ handler: @escaping (QualityMetrics) -> Void)
```

Sets up a handler for quality metrics changes.

**Parameters:**
- `handler`: Closure called when quality metrics change

**Example:**
```swift
callQualityManager.onQualityMetricsChanged { metrics in
    print("📊 Video bitrate: \(metrics.videoBitrate) bps")
    print("📊 Audio bitrate: \(metrics.audioBitrate) bps")
    print("📊 Frame rate: \(metrics.frameRate) fps")
    print("📊 Resolution: \(metrics.resolution)")
    print("📊 Packet loss: \(metrics.packetLoss)%")
    print("📊 Latency: \(metrics.latency)ms")
}
```

```swift
func optimizeQuality(for networkCondition: NetworkCondition)
```

Optimizes call quality for the current network condition.

**Parameters:**
- `networkCondition`: The current network condition

**Example:**
```swift
callQualityManager.optimizeQuality(for: .poor) { result in
    switch result {
    case .success:
        print("✅ Quality optimized for poor network")
    case .failure(let error):
        print("❌ Quality optimization failed: \(error)")
    }
}
```

## VoiceVideoError

Represents voice and video errors.

### Error Types

```swift
enum VoiceVideoError: Error {
    case callFailed(String)
    case connectionFailed(String)
    case mediaError(String)
    case deviceNotFound(String)
    case permissionDenied(String)
    case networkError(String)
    case codecNotSupported(String)
    case sessionExpired(String)
    case invalidCallId(String)
    case callBusy(String)
    case callRejected(String)
    case callTimeout(String)
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
voiceVideoManager.onError { error in
    switch error {
    case .callFailed(let reason):
        print("❌ Call failed: \(reason)")
    case .connectionFailed(let reason):
        print("❌ Connection failed: \(reason)")
    case .mediaError(let message):
        print("❌ Media error: \(message)")
    case .deviceNotFound(let device):
        print("❌ Device not found: \(device)")
    case .permissionDenied(let resource):
        print("❌ Permission denied: \(resource)")
    case .networkError(let message):
        print("❌ Network error: \(message)")
    case .codecNotSupported(let codec):
        print("❌ Codec not supported: \(codec)")
    case .sessionExpired(let sessionId):
        print("❌ Session expired: \(sessionId)")
    case .invalidCallId(let callId):
        print("❌ Invalid call ID: \(callId)")
    case .callBusy(let userId):
        print("❌ Call busy: \(userId)")
    case .callRejected(let reason):
        print("❌ Call rejected: \(reason)")
    case .callTimeout(let callId):
        print("❌ Call timeout: \(callId)")
    }
}
```

## Enums

### CallType

```swift
enum CallType {
    case voice
    case video
}
```

### CallState

```swift
enum CallState {
    case connecting
    case connected
    case disconnected
    case failed(VoiceVideoError)
    case ended
}
```

### VideoCallState

```swift
enum VideoCallState {
    case connecting
    case connected
    case disconnected
    case failed(VoiceVideoError)
    case ended
}
```

### AudioCodec

```swift
enum AudioCodec {
    case opus
    case pcm
    case g711
}
```

### VideoCodec

```swift
enum VideoCodec {
    case h264
    case h265
    case vp8
    case vp9
}
```

### VideoResolution

```swift
enum VideoResolution {
    case qvga
    case vga
    case hd720p
    case hd1080p
}
```

### NetworkCondition

```swift
enum NetworkCondition {
    case excellent
    case good
    case fair
    case poor
}
```

## Complete Example

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

This comprehensive API documentation covers all aspects of the Voice & Video module in the iOS Real-Time Communication Framework. For more examples and advanced usage, refer to the Voice & Video Guide and other documentation.
