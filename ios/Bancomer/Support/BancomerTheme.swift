import SwiftUI

enum BancomerTheme {
    static let titlebar = Color(red: 5 / 255, green: 23 / 255, blue: 48 / 255)
    static let app = Color(red: 14 / 255, green: 30 / 255, blue: 51 / 255)
    static let backdrop = Color(red: 10 / 255, green: 21 / 255, blue: 38 / 255)
    static let hairline = Color(red: 32 / 255, green: 57 / 255, blue: 91 / 255)
    static let ink = Color(red: 232 / 255, green: 238 / 255, blue: 245 / 255)
    static let inkDim = Color(red: 159 / 255, green: 179 / 255, blue: 200 / 255)
    static let inkFaint = Color(red: 102 / 255, green: 128 / 255, blue: 155 / 255)
    static let positive = Color(red: 53 / 255, green: 179 / 255, blue: 146 / 255)
    static let negative = Color(red: 240 / 255, green: 114 / 255, blue: 133 / 255)
    static let aqua = Color(red: 73 / 255, green: 165 / 255, blue: 230 / 255)

    static let hero = LinearGradient(
        colors: [titlebar, Color(red: 10 / 255, green: 46 / 255, blue: 92 / 255)],
        startPoint: .top,
        endPoint: .bottom
    )

    static func color(for category: ExpenseCategory) -> Color {
        switch category {
        case .housing: Color(red: 156 / 255, green: 202 / 255, blue: 240 / 255)
        case .health: Color(red: 58 / 255, green: 110 / 255, blue: 168 / 255)
        case .debt: Color(red: 111 / 255, green: 174 / 255, blue: 227 / 255)
        case .food: Color(red: 199 / 255, green: 225 / 255, blue: 248 / 255)
        case .ai: Color(red: 78 / 255, green: 143 / 255, blue: 208 / 255)
        }
    }
}
