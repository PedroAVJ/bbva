import Foundation
import Testing
@testable import Bancomer

struct LedgerTests {
    @Test func summarySeparatesIncomeExpenseAndRecurrence() {
        let transactions = [
            LedgerTransaction(kind: .income, amount: 45_000, description: "Salary", category: nil, forWho: "Me", recurring: true),
            LedgerTransaction(kind: .expense, amount: 4_500, description: "Care", category: .health, forWho: "family", recurring: true),
            LedgerTransaction(kind: .expense, amount: 780, description: "Prescription", category: .health, forWho: "mom", recurring: false),
        ]

        let summary = LedgerSummary.make(from: transactions)

        #expect(summary.income == 45_000)
        #expect(summary.expenses == 5_280)
        #expect(summary.recurring == 4_500)
        #expect(summary.oneTime == 780)
        #expect(summary.net == 39_720)
    }

    @Test func persistenceRoundTripsTransactions() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        let persistence = LedgerPersistence(fileURL: directory.appending(path: "transactions.json"))
        let expected = [
            LedgerTransaction(kind: .expense, amount: 1_250, description: "Internet", category: .housing, forWho: "household", recurring: true),
        ]

        try persistence.save(expected)
        let actual = try persistence.load()

        #expect(actual == expected)
        try? FileManager.default.removeItem(at: directory)
    }
}
