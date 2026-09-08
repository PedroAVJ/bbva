import Foundation

struct DashboardSnapshot: Codable, Equatable, Sendable {
    let schemaVersion: Int
    let dataMode: String
    let asOfDate: String
    let dateLabel: String
    let currency: String
    let balanceMxn: Double
    let dailyCreditMxn: Double
    let spentTodayMxn: Double
    let typicalSlackDailyMxn: Double
    let incomeMonthlyMxn: Double
    let typicalVariableMonthlyMxn: Double
    let outlierNote: String
    let dailyNetsMxn: [Double]
    let categories: [DashboardCategory]

    var isSample: Bool { dataMode == "sample" }
    var incomeDailyMxn: Double { incomeMonthlyMxn / 30 }

    var recovery: RecoveryStatus {
        RecoveryStatus(
            balanceMxn: balanceMxn,
            dailyCreditMxn: dailyCreditMxn,
            typicalSlackDailyMxn: typicalSlackDailyMxn,
            asOfDate: asOfDate
        )
    }
}

struct DashboardCategory: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let name: String
    let subtitle: String
    let monthlyMxn: Double
    let color: String
    let note: String
    let footnote: String
    let items: [DashboardItem]

    var dailyMxn: Double { monthlyMxn / 30 }

    func incomePercent(in snapshot: DashboardSnapshot) -> Double {
        guard snapshot.incomeMonthlyMxn > 0 else { return 0 }
        return monthlyMxn / snapshot.incomeMonthlyMxn * 100
    }
}

struct DashboardItem: Codable, Equatable, Identifiable, Sendable {
    let name: String
    let monthlyMxn: Double

    var id: String { name }
    var dailyMxn: Double { monthlyMxn / 30 }

    func categoryPercent(in category: DashboardCategory) -> Double {
        guard category.monthlyMxn > 0 else { return 0 }
        return monthlyMxn / category.monthlyMxn * 100
    }
}

struct RecoveryStatus: Equatable, Sendable {
    let noSpendDays: Int
    let typicalPaceDays: Int
    let typicalPaceDate: Date?

    init(
        balanceMxn: Double,
        dailyCreditMxn: Double,
        typicalSlackDailyMxn: Double,
        asOfDate: String
    ) {
        let deficit = abs(min(balanceMxn, 0))
        noSpendDays = Self.daysToRecover(deficit: deficit, rate: dailyCreditMxn)
        typicalPaceDays = Self.daysToRecover(deficit: deficit, rate: typicalSlackDailyMxn)

        if let date = FinanceFormat.isoDate(asOfDate) {
            typicalPaceDate = Calendar.gregorianUTC.date(
                byAdding: .day,
                value: typicalPaceDays,
                to: date
            )
        } else {
            typicalPaceDate = nil
        }
    }

    private static func daysToRecover(deficit: Double, rate: Double) -> Int {
        guard deficit > 0, rate > 0 else { return 0 }
        return Int(ceil(deficit / rate))
    }
}

private extension Calendar {
    static var gregorianUTC: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
}
