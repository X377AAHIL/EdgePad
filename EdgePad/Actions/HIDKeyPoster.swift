import Cocoa

enum MediaKey: Int32 {
    case soundUp = 0
    case soundDown = 1
    case brightnessUp = 2
    case brightnessDown = 3
    case mute = 7
    case play = 16
    case next = 17
    case previous = 18
    case illuminationUp = 21
    case illuminationDown = 22
}

enum HIDKeyPoster {
    static func post(_ key: MediaKey, fineGrained: Bool = false) {
        send(key, isDown: true, fineGrained: fineGrained)
        send(key, isDown: false, fineGrained: fineGrained)
    }

    private static func send(_ key: MediaKey, isDown: Bool, fineGrained: Bool) {
        let state = isDown ? 0x0A : 0x0B
        var flagBits = UInt(state << 8)
        if fineGrained {
            flagBits |= NSEvent.ModifierFlags.shift.rawValue
            flagBits |= NSEvent.ModifierFlags.option.rawValue
        }

        let data1 = Int((key.rawValue << 16) | Int32(state << 8))

        guard let event = NSEvent.otherEvent(
            with: .systemDefined,
            location: .zero,
            modifierFlags: NSEvent.ModifierFlags(rawValue: flagBits),
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: 0,
            context: nil,
            subtype: 8,
            data1: data1,
            data2: -1
        ) else { return }

        event.cgEvent?.post(tap: .cghidEventTap)
    }
}