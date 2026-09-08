import Foundation

enum FinanceFormat {
    static func amount(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: value as NSDecimalNumber) ?? "0"
    }

    static func percentage(_ value: Decimal, of whole: Decimal) -> Int {
        guard whole > 0 else { return 0 }
        let ratio = NSDecimalNumber(decimal: value / whole).doubleValue
        return Int((ratio * 100).rounded())
    }

    static func shortDate(_ value: Date) -> String {
        value.formatted(.dateTime.month(.abbreviated).day())
    }

    static func monthRange(now: Date = .now) -> String {
        let month = now.formatted(.dateTime.month(.abbreviated))
        return "\(month) 1–\(Calendar.current.component(.day, from: now))"
    }
}
