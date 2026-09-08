import AppKit
import SwiftUI

enum BBVATheme {
    static let navy = Color(hex: "#051730")
    static let background = Color(hex: "#0E1E33")
    static let backgroundDeep = Color(hex: "#0A1526")
    static let line = Color(hex: "#20395B")
    static let ink = Color(hex: "#E8EEF5")
    static let inkDim = Color(hex: "#9FB3C8")
    static let inkFaint = Color(hex: "#66809B")
    static let coral = Color(hex: "#F07285")
    static let teal = Color(hex: "#35B392")
    static let aqua = Color(hex: "#49A5E6")
    static let aquaHover = Color(hex: "#5BBEFF")
    static let heroEnd = Color(hex: "#0A2E5C")
    static let heroSubtext = Color(hex: "#8FB8DA")

    static let pushAnimation = Animation.timingCurve(
        0.32,
        0.72,
        0.35,
        1,
        duration: 0.34
    )

    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Libre Franklin", fixedSize: size).weight(weight)
    }

    static func serif(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Source Serif 4", fixedSize: size).weight(weight)
    }
}

extension Color {
    init(hex: String) {
        let value = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var integer: UInt64 = 0
        Scanner(string: value).scanHexInt64(&integer)

        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        switch value.count {
        case 8:
            red = Double((integer >> 24) & 0xFF) / 255
            green = Double((integer >> 16) & 0xFF) / 255
            blue = Double((integer >> 8) & 0xFF) / 255
            alpha = Double(integer & 0xFF) / 255
        default:
            red = Double((integer >> 16) & 0xFF) / 255
            green = Double((integer >> 8) & 0xFF) / 255
            blue = Double(integer & 0xFF) / 255
            alpha = 1
        }

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    static func shaded(hex: String, index: Int, count: Int) -> Color {
        let fraction = count <= 1 ? 0 : CGFloat(index) / CGFloat(count - 1) * 0.5
        let base = NSColor(hex: hex)
        return Color(nsColor: base.blended(withFraction: fraction, of: .white) ?? base)
    }
}

extension NSColor {
    convenience init(hex: String) {
        let value = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var integer: UInt64 = 0
        Scanner(string: value).scanHexInt64(&integer)
        self.init(
            srgbRed: CGFloat((integer >> 16) & 0xFF) / 255,
            green: CGFloat((integer >> 8) & 0xFF) / 255,
            blue: CGFloat(integer & 0xFF) / 255,
            alpha: 1
        )
    }
}
