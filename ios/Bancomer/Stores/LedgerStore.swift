import Foundation
import Combine

@MainActor
final class LedgerStore: ObservableObject {
    @Published private(set) var transactions: [LedgerTransaction] = []
    @Published private(set) var persistenceError: String?

    private let persistence: LedgerPersistence
    private let calendar: Calendar

    init(persistence: LedgerPersistence = LedgerPersistence(), calendar: Calendar = .current) {
        self.persistence = persistence
        self.calendar = calendar
        do {
            transactions = try persistence.load()
        } catch {
            persistenceError = "Your saved ledger could not be opened."
        }
    }

    var thisMonthTransactions: [LedgerTransaction] {
        transactions
            .filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .month) }
            .sorted { $0.date > $1.date }
    }

    var summary: LedgerSummary {
        LedgerSummary.make(from: thisMonthTransactions)
    }

    func transactions(for category: ExpenseCategory) -> [LedgerTransaction] {
        thisMonthTransactions.filter { $0.kind == .expense && $0.category == category }
    }

    func add(_ transaction: LedgerTransaction) {
        transactions.append(transaction)
        do {
            try persistence.save(transactions)
            persistenceError = nil
        } catch {
            transactions.removeAll { $0.id == transaction.id }
            persistenceError = "That transaction could not be saved."
        }
    }

    func clearPersistenceError() {
        persistenceError = nil
    }
}
