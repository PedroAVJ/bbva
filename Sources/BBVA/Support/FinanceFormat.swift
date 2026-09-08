import Foundation

enum FinanceFormat {
    private static let wholeNumber: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    private static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    static func whole(_ value: Double) -> String {
        wholeNumber.string(from: NSNumber(value: value)) ?? String(Int(value.rounded()))
    }

    static func signedWhole(_ value: Double) -> String {
        let sign = value < 0 ? "−" : value > 0 ? "+" : ""
        return sign + whole(abs(value))
    }

    static func isoDate(_ value: String) -> Date? {
        isoFormatter.date(from: value)
    }

    static func shortDate(_ date: Date?) -> String {
        guard let date else { return "—" }
        return shortDateFormatter.string(from: date)
    }
}
