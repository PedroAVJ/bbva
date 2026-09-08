import Testing
@testable import BBVA

@Suite("BBVA dashboard model")
struct DashboardModelTests {
    @Test("Seed snapshot decodes and remains explicitly sample data")
    func seedSnapshot() throws {
        let snapshot = try SeedDashboardDataSource().loadSnapshot()
        #expect(snapshot.isSample)
        #expect(snapshot.balanceMxn == -1_200)
        #expect(snapshot.categories.count == 6)
        #expect(snapshot.dailyNetsMxn.count == 14)
    }

    @Test("Infinite-carry recovery math matches the design")
    func recoveryMath() throws {
        let snapshot = try SeedDashboardDataSource().loadSnapshot()
        #expect(snapshot.recovery.noSpendDays == 3)
        #expect(snapshot.recovery.typicalPaceDays == 30)
        #expect(FinanceFormat.shortDate(snapshot.recovery.typicalPaceDate) == "Feb 14")
    }

    @Test("Income categories reconcile to the monthly total")
    func categoriesReconcile() throws {
        let snapshot = try SeedDashboardDataSource().loadSnapshot()
        let total = snapshot.categories.reduce(0) { $0 + $1.monthlyMxn }
        #expect(abs(total - snapshot.incomeMonthlyMxn) < 0.02)
        #expect(Int(snapshot.dailyCreditMxn.rounded()) == 400)
    }
}
