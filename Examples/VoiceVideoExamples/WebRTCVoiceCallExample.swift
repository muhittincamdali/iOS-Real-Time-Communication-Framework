import Foundation
import RealTimeCommunicationFramework

// MARK: - WebRTC Voice Call Example
// This example demonstrates WebRTC voice calling capabilities

class WebRTCVoiceCallExample {
    
    private let voiceCallManager = WebRTCVoiceCall()
    private var currentCall: VoiceCall?
    private var isInCall = false
    
    func setupVoiceCall() {
        let config = VoiceCallConfiguration()
        config.enableEchoCancellation = true
        config.enableNoiseSuppression = true
        config.enableAutomaticGainControl = true
        config.audioCodec = .opus
        config.sampleRate = 48000
        config.channels = 1
        config.bitrate = 64000
        
        voiceCallManager.configure(config)
        setupEventHandlers()
    }
    
    private func setupEventHandlers() {
        voiceCallManager.onCallStateChanged { state in
            self.handleCallStateChange(state)
        }
        
        voiceCallManager.onAudioLevelChanged { level in
            print("🎤 Audio level: \(level) dB")
        }
        
        voiceCallManager.onCallQualityChanged { quality in
            print("📊 Call quality: \(quality.rawValue)")
        }
        
        voiceCallManager.onError { error in
            print("❌ Voice call error: \(error)")
        }
    }
    
    func startCall(with userId: String) async {
        do {
            let call = try await voiceCallManager.startCall(with: userId)
            currentCall = call
            isInCall = true
            print("✅ Voice call started with \(userId)")
            print("Call ID: \(call.callId)")
            print("Status: \(call.status)")
        } catch {
            print("❌ Failed to start call: \(error)")
        }
    }
    
    func answerCall(_ callId: String) async {
        do {
            let call = try await voiceCallManager.answerCall(callId)
            currentCall = call
            isInCall = true
            print("✅ Call answered: \(callId)")
        } catch {
            print("❌ Failed to answer call: \(error)")
        }
    }
    
    func endCall() async {
        guard let call = currentCall else {
            print("❌ No active call to end")
            return
        }
        
        do {
            try await voiceCallManager.endCall(call.callId)
            currentCall = nil
            isInCall = false
            print("✅ Call ended: \(call.callId)")
        } catch {
            print("❌ Failed to end call: \(error)")
        }
    }
    
    func muteCall(_ muted: Bool) async {
        guard let call = currentCall else {
            print("❌ No active call to mute")
            return
        }
        
        do {
            try await voiceCallManager.setMuted(muted, for: call.callId)
            print("✅ Call \(muted ? "muted" : "unmuted")")
        } catch {
            print("❌ Failed to \(muted ? "mute" : "unmute") call: \(error)")
        }
    }
    
    func holdCall(_ held: Bool) async {
        guard let call = currentCall else {
            print("❌ No active call to hold")
            return
        }
        
        do {
            try await voiceCallManager.setHold(held, for: call.callId)
            print("✅ Call \(held ? "held" : "resumed")")
        } catch {
            print("❌ Failed to \(held ? "hold" : "resume") call: \(error)")
        }
    }
    
    private func handleCallStateChange(_ state: VoiceCallState) {
        switch state {
        case .idle:
            print("📞 Call state: Idle")
        case .dialing:
            print("📞 Call state: Dialing...")
        case .incoming:
            print("📞 Call state: Incoming call")
        case .connecting:
            print("📞 Call state: Connecting...")
        case .connected:
            print("📞 Call state: Connected")
        case .disconnected:
            print("📞 Call state: Disconnected")
            isInCall = false
            currentCall = nil
        case .failed(let error):
            print("📞 Call state: Failed - \(error)")
            isInCall = false
            currentCall = nil
        case .held:
            print("📞 Call state: On hold")
        case .muted:
            print("📞 Call state: Muted")
        }
    }
    
    func getCallStatistics() -> CallStatistics? {
        guard let call = currentCall else { return nil }
        
        return voiceCallManager.getCallStatistics(for: call.callId)
    }
    
    func setAudioDevice(_ device: AudioDevice) async {
        do {
            try await voiceCallManager.setAudioDevice(device)
            print("✅ Audio device changed to: \(device.name)")
        } catch {
            print("❌ Failed to change audio device: \(error)")
        }
    }
    
    func getAvailableAudioDevices() -> [AudioDevice] {
        return voiceCallManager.getAvailableAudioDevices()
    }
}

// MARK: - Data Models
struct VoiceCall {
    let callId: String
    let remoteUserId: String
    let status: VoiceCallState
    let startTime: Date
    let duration: TimeInterval
}

enum VoiceCallState {
    case idle
    case dialing
    case incoming
    case connecting
    case connected
    case disconnected
    case failed(Error)
    case held
    case muted
}

enum CallQuality: String {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    case bad = "bad"
}

struct CallStatistics {
    let duration: TimeInterval
    let audioLevel: Double
    let quality: CallQuality
    let packetLoss: Double
    let latency: TimeInterval
    let jitter: TimeInterval
}

struct AudioDevice {
    let id: String
    let name: String
    let type: AudioDeviceType
    
    enum AudioDeviceType {
        case speaker
        case earpiece
        case bluetooth
        case wired
    }
}

// MARK: - Usage Example
func runWebRTCVoiceCallExample() async {
    let voiceCall = WebRTCVoiceCallExample()
    
    // Setup voice call
    voiceCall.setupVoiceCall()
    
    // Get available audio devices
    let devices = voiceCall.getAvailableAudioDevices()
    print("🎧 Available audio devices:")
    for device in devices {
        print("  - \(device.name) (\(device.type))")
    }
    
    // Set audio device
    if let speaker = devices.first(where: { $0.type == .speaker }) {
        await voiceCall.setAudioDevice(speaker)
    }
    
    // Start a call
    await voiceCall.startCall(with: "user456")
    
    // Wait for connection
    try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
    
    // Mute the call
    await voiceCall.muteCall(true)
    
    // Wait a bit
    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
    
    // Unmute the call
    await voiceCall.muteCall(false)
    
    // Get call statistics
    if let stats = voiceCall.getCallStatistics() {
        print("📊 Call Statistics:")
        print("  Duration: \(Int(stats.duration))s")
        print("  Audio Level: \(stats.audioLevel) dB")
        print("  Quality: \(stats.quality.rawValue)")
        print("  Packet Loss: \(stats.packetLoss)%")
        print("  Latency: \(Int(stats.latency * 1000))ms")
        print("  Jitter: \(Int(stats.jitter * 1000))ms")
    }
    
    // Hold the call
    await voiceCall.holdCall(true)
    
    // Wait a bit
    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
    
    // Resume the call
    await voiceCall.holdCall(false)
    
    // Wait a bit more
    try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
    
    // End the call
    await voiceCall.endCall()
}

// MARK: - Example Output
/*
🎧 Available audio devices:
  - Speaker (speaker)
  - Earpiece (earpiece)
  - AirPods Pro (bluetooth)
✅ Audio device changed to: Speaker
📞 Call state: Dialing...
📞 Call state: Connecting...
📞 Call state: Connected
✅ Voice call started with user456
Call ID: call_123456
Status: connected
🎤 Audio level: -45.2 dB
📊 Call quality: excellent
✅ Call muted
✅ Call unmuted
📊 Call Statistics:
  Duration: 8s
  Audio Level: -42.1 dB
  Quality: excellent
  Packet Loss: 0.1%
  Latency: 45ms
  Jitter: 12ms
✅ Call held
✅ Call resumed
📞 Call state: Disconnected
✅ Call ended: call_123456
*/ 