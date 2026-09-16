import Foundation

enum SystemBrightness {
    static func nudge(_ direction: Int, fineGrained: Bool = false) {
        HIDKeyPoster.post(direction > 0 ? .brightnessUp : .brightnessDown, fineGrained: fineGrained)
    }
}

enum KeyboardBacklight {
    static func nudge(_ direction: Int) {
        HIDKeyPoster.post(direction > 0 ? .illuminationUp : .illuminationDown)
    }
}