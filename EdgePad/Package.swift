// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "EdgePad",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "EdgePad", targets: ["EdgePad"])
    ],
    targets: [
        .executableTarget(
            name: "EdgePad",
            path: ".",
            exclude: [
                "EdgePad-macOS27-Build-Guide.pdf",
                "Info.plist",
                "agents.md",
                "changelog.md",
                "progress.md"
            ],
            sources: [
                "EdgePadApp.swift",
                "AppDelegate.swift",
                "ContentView.swift",
                "Core/TrackpadEdge.swift",
                "Core/EdgeBinding.swift",
                "Core/EdgeGestureRecognizer.swift",
                "Core/ConfigurationStore.swift",
                "Input/TrackpadTouchView.swift",
                "Input/GestureEventTap.swift",
                "Actions/SystemVolume.swift",
                "Actions/SystemBrightness.swift",
                "Actions/HIDKeyPoster.swift",
                "Permissions/PermissionChecker.swift",
                "UI/TouchDebugView.swift",
                "UI/PreferencesView.swift"
            ],
            resources: [
                .process("Assets.xcassets")
            ],
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("CoreAudio"),
                .linkedFramework("AudioToolbox"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("ServiceManagement"),
                .linkedFramework("IOKit")
            ]
        )
    ]
)
