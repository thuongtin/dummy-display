import AppKit
import Foundation

let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconsetURL = rootURL.appendingPathComponent("build/icon/AppIcon.iconset", isDirectory: true)
let icnsURL = rootURL.appendingPathComponent("DummyDisplay/Resources/AppIcon.icns")

try? FileManager.default.removeItem(at: iconsetURL)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)
try FileManager.default.createDirectory(at: icnsURL.deletingLastPathComponent(), withIntermediateDirectories: true)

struct IconImage {
    let filename: String
    let pixels: Int
}

let images = [
    IconImage(filename: "icon_16x16.png", pixels: 16),
    IconImage(filename: "icon_16x16@2x.png", pixels: 32),
    IconImage(filename: "icon_32x32.png", pixels: 32),
    IconImage(filename: "icon_32x32@2x.png", pixels: 64),
    IconImage(filename: "icon_128x128.png", pixels: 128),
    IconImage(filename: "icon_128x128@2x.png", pixels: 256),
    IconImage(filename: "icon_256x256.png", pixels: 256),
    IconImage(filename: "icon_256x256@2x.png", pixels: 512),
    IconImage(filename: "icon_512x512.png", pixels: 512),
    IconImage(filename: "icon_512x512@2x.png", pixels: 1024),
]

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1.0) -> NSColor {
    NSColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
}

func roundedRect(_ rect: CGRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func drawIcon(size: Int) -> NSImage {
    let canvas = CGFloat(size)
    let image = NSImage(size: NSSize(width: canvas, height: canvas))
    image.lockFocus()

    NSGraphicsContext.current?.imageInterpolation = .high
    NSGraphicsContext.current?.shouldAntialias = true

    let bounds = CGRect(x: 0, y: 0, width: canvas, height: canvas)
    color(19, 24, 33).setFill()
    roundedRect(bounds.insetBy(dx: canvas * 0.035, dy: canvas * 0.035), radius: canvas * 0.22).fill()

    let glowPath = roundedRect(bounds.insetBy(dx: canvas * 0.095, dy: canvas * 0.095), radius: canvas * 0.18)
    color(36, 214, 144, 0.18).setFill()
    glowPath.fill()

    let screenRect = CGRect(x: canvas * 0.18, y: canvas * 0.29, width: canvas * 0.64, height: canvas * 0.47)
    color(235, 241, 249).setFill()
    roundedRect(screenRect, radius: canvas * 0.055).fill()

    let inner = screenRect.insetBy(dx: canvas * 0.055, dy: canvas * 0.055)
    color(28, 37, 52).setFill()
    roundedRect(inner, radius: canvas * 0.033).fill()

    let virtualScreen = inner.insetBy(dx: canvas * 0.055, dy: canvas * 0.052)
    color(42, 230, 153).setStroke()
    let virtualPath = roundedRect(virtualScreen, radius: canvas * 0.02)
    virtualPath.lineWidth = max(1, canvas * 0.018)
    let dash: [CGFloat] = [canvas * 0.052, canvas * 0.032]
    virtualPath.setLineDash(dash, count: dash.count, phase: 0)
    virtualPath.stroke()

    color(235, 241, 249).setFill()
    let neck = CGRect(x: canvas * 0.455, y: canvas * 0.205, width: canvas * 0.09, height: canvas * 0.09)
    roundedRect(neck, radius: canvas * 0.018).fill()

    let base = CGRect(x: canvas * 0.33, y: canvas * 0.16, width: canvas * 0.34, height: canvas * 0.06)
    roundedRect(base, radius: canvas * 0.03).fill()

    let dotRect = CGRect(x: canvas * 0.685, y: canvas * 0.635, width: canvas * 0.075, height: canvas * 0.075)
    color(42, 230, 153).setFill()
    NSBezierPath(ovalIn: dotRect).fill()

    image.unlockFocus()
    return image
}

func writePNG(_ image: NSImage, to url: URL, pixels: Int) throws {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "local.codex.dummy-display.icon", code: 1)
    }
    bitmap.size = NSSize(width: pixels, height: pixels)
    try data.write(to: url)
}

for item in images {
    let image = drawIcon(size: item.pixels)
    try writePNG(image, to: iconsetURL.appendingPathComponent(item.filename), pixels: item.pixels)
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetURL.path, "-o", icnsURL.path]
try process.run()
process.waitUntilExit()

if process.terminationStatus != 0 {
    throw NSError(domain: "local.codex.dummy-display.icon", code: Int(process.terminationStatus))
}

print("Generated \(icnsURL.path)")
