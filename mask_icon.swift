import Cocoa

let args = CommandLine.arguments
guard args.count == 3 else {
    print("Usage: swift mask_icon.swift <input> <output>")
    exit(1)
}

let inputPath = args[1]
let outputPath = args[2]

guard let image = NSImage(contentsOfFile: inputPath) else {
    print("Could not load image at \(inputPath)")
    exit(1)
}

let size = image.size
// App icon radius is typically 22.5% of the side length.
let radius = size.width * 0.225

let newImage = NSImage(size: size)
newImage.lockFocus()

// Clear background
NSColor.clear.set()
NSRect(origin: .zero, size: size).fill()

let rect = NSRect(origin: .zero, size: size)
let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
path.addClip()
image.draw(in: rect)

newImage.unlockFocus()

guard let tiffData = newImage.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    print("Could not generate PNG data")
    exit(1)
}

do {
    try pngData.write(to: URL(fileURLWithPath: outputPath))
    print("Saved rounded image to \(outputPath)")
} catch {
    print("Error saving: \(error)")
    exit(1)
}
