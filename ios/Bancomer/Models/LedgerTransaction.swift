import Foundation

enum TransactionKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case expense
    case income

    var id: String { rawValue }
}

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case housing
    case health
    case debt
    case food
    case ai

    var id: String { rawValue }

    var name: String {
        switch self {
        case .housing: "Housing & utilities"
        case .health: "Health"
        case .debt: "Debt"
        case .food: "Food & daily"
        case .ai: "AI"
        }
    }

    var note: String {
        switch self {
        case .housing: "Housing, power, internet, and other household commitments."
        case .health: "Care, medication, and other health commitments."
        case .debt: "Obligations with a fixed or expected schedule."
        case .food: "Food, transport, shopping, and ordinary day-to-day spending."
        case .ai: "AI services, software, and related tools."
        }
    }
}

struct LedgerTransaction: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    let kind: TransactionKind
    let amount: Decimal
    let description: String
    let category: ExpenseCategory?
    let forWho: String
    let recurring: Bool
    let date: Date

    init(
        id: UUID = UUID(),
        kind: TransactionKind,
        amount: Decimal,
        description: String,
        category: ExpenseCategory?,
        forWho: String,
        recurring: Bool,
        date: Date = .now
    ) {
        self.id = id
        self.kind = kind
        self.amount = amount
        self.description = description
        self.category = kind == .income ? nil : category
        self.forWho = forWho
        self.recurring = recurring
        self.date = date
    }
}

struct LedgerSummary: Equatable, Sendable {
    let income: Decimal
    let expenses: Decimal
    let recurring: Decimal
    let oneTime: Decimal

    var net: Decimal { income - expenses }

    static func make(from transactions: [LedgerTransaction]) -> LedgerSummary {
        var income: Decimal = 0
        var expenses: Decimal = 0
        var recurring: Decimal = 0
        var oneTime: Decimal = 0

        for transaction in transactions {
            if transaction.kind == .income {
                income += transaction.amount
            } else {
                expenses += transaction.amount
                if transaction.recurring {
                    recurring += transaction.amount
                } else {
                    oneTime += transaction.amount
                }
            }
        }

        return LedgerSummary(
            income: income,
            expenses: expenses,
            recurring: recurring,
            oneTime: oneTime
        )
    }
}
