import AppKit
import SwiftUI

struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async { configure(view.window) }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { configure(nsView.window) }
    }

    private func configure(_ window: NSWindow?) {
        guard let window else { return }
        window.title = "BBVA"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)
        window.styleMask.remove(.resizable)
        window.isMovableByWindowBackground = true
        window.tabbingMode = .disallowed
        window.backgroundColor = NSColor(hex: "#0E1E33")
        window.minSize = NSSize(width: 420, height: 598)
        window.maxSize = NSSize(width: 420, height: 598)
        window.standardWindowButton(.zoomButton)?.isEnabled = false

        if window.frame.size != NSSize(width: 420, height: 598) {
            let top = window.frame.maxY
            window.setFrame(
                NSRect(
                    x: window.frame.origin.x,
                    y: top - 598,
                    width: 420,
                    height: 598
                ),
                display: true
            )
        }
    }
}
