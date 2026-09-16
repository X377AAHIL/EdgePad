import Foundation
import CoreAudio
import AudioToolbox

enum SystemVolume {

    private static var defaultOutputDevice: AudioDeviceID? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address, 0, nil, &size, &deviceID
        )

        return status == noErr && deviceID != kAudioObjectUnknown ? deviceID : nil
    }

    private static let volumeAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
        mScope: kAudioDevicePropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMain
    )

    static var isSupported: Bool {
        guard let device = defaultOutputDevice else { return false }
        var address = volumeAddress
        return AudioObjectHasProperty(device, &address)
    }

    static func current() -> Float? {
        guard let device = defaultOutputDevice else { return nil }
        var address = volumeAddress
        var value = Float32(0)
        var size = UInt32(MemoryLayout<Float32>.size)
        let status = AudioObjectGetPropertyData(device, &address, 0, nil, &size, &value)
        return status == noErr ? value : nil
    }

    @discardableResult
    static func set(_ newValue: Float) -> Bool {
        guard let device = defaultOutputDevice else { return false }
        var address = volumeAddress
        var value = Float32(min(max(newValue, 0), 1))
        let status = AudioObjectSetPropertyData(
            device, &address, 0, nil,
            UInt32(MemoryLayout<Float32>.size), &value
        )
        if status == noErr && value > 0 { setMuted(false) }
        return status == noErr
    }

    static func setMuted(_ muted: Bool) {
        guard let device = defaultOutputDevice else { return }
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        guard AudioObjectHasProperty(device, &address) else { return }
        var value: UInt32 = muted ? 1 : 0
        AudioObjectSetPropertyData(
            device, &address, 0, nil,
            UInt32(MemoryLayout<UInt32>.size), &value
        )
    }

    static func nudge(_ direction: Int, step: Float = 1.0 / 16.0) {
        // Core Audio changes the volume silently. Since the user wants to see it working 
        // similar to brightness (which shows the HUD), we use the media-key path for all volume nudges.
        HIDKeyPoster.post(direction > 0 ? .soundUp : .soundDown)
    }
}