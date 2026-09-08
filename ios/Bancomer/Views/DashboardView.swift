import SwiftUI

struct DashboardView: View {
    @ObservedObject var store: LedgerStore
    @State private var showsAddTransaction = false

    private struct CategoryTotal: Identifiable {
        let category: ExpenseCategory
        let transactions: [LedgerTransaction]
        let total: Decimal
        var id: ExpenseCategory { category }
    }

    private var categoryTotals: [CategoryTotal] {
        ExpenseCategory.allCases
            .map { category in
                let transactions = store.transactions(for: category)
                return CategoryTotal(
                    category: category,
                    transactions: transactions,
                    total: transactions.reduce(Decimal.zero) { $0 + $1.amount }
                )
            }
            .filter { $0.total > 0 }
            .sorted { $0.total > $1.total }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        hero
                        expenseComposition
                        recurringSplit
                        recentTransactions
                    }
                }
                .scrollIndicators(.hidden)

                Button {
                    showsAddTransaction = true
                } label: {
                    Label("Add transaction", systemImage: "plus")
                        .font(.custom("Libre Franklin", size: 14).weight(.semibold))
                        .padding(.horizontal, 8)
                }
                .buttonStyle(.glassProminent)
                .tint(BancomerTheme.titlebar)
                .padding(.bottom, 10)
                .accessibilityHint("Opens the on-device transaction form")
            }
            .background(BancomerTheme.app.ignoresSafeArea())
            .navigationTitle("Bancomer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: ExpenseCategory.self) { category in
                CategoryDetailView(store: store, category: category)
            }
            .sheet(isPresented: $showsAddTransaction) {
                AddTransactionView(store: store)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .alert("Could not save", isPresented: Binding(
                get: { store.persistenceError != nil },
                set: { if !$0 { store.clearPersistenceError() } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(store.persistenceError ?? "The transaction remains unchanged.")
            }
        }
        .tint(BancomerTheme.aqua)
    }

    private var hero: some View {
        let summary = store.summary
        return VStack(alignment: .leading, spacing: 0) {
            Text("NET THIS MONTH")
                .font(.custom("Libre Franklin", size: 11).weight(.bold))
                .tracking(0.7)
                .foregroundStyle(BancomerTheme.aqua)

            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text("\(summary.net < 0 ? "−" : "+")\(FinanceFormat.amount(abs(summary.net)))")
                    .font(.custom("Source Serif 4", size: 54).weight(.semibold))
                    .tracking(-1.2)
                    .monospacedDigit()
                    .foregroundStyle(summary.net < 0 ? BancomerTheme.negative : BancomerTheme.positive)
                    .minimumScaleFactor(0.65)
                    .lineLimit(1)
                Text("MXN · \(FinanceFormat.monthRange())")
                    .font(.custom("Libre Franklin", size: 12))
                    .foregroundStyle(BancomerTheme.ink.opacity(0.64))
            }
            .padding(.top, 7)

            HStack(spacing: 36) {
                PrimaryFact(title: "Income", amount: summary.income, positive: true)
                PrimaryFact(title: "Expenses", amount: summary.expenses, positive: false)
            }
            .padding(.top, 14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 22)
        .padding(.bottom, 18)
        .background(BancomerTheme.hero)
    }

    private var expenseComposition: some View {
        LedgerSection {
            SectionHeading(title: "WHERE EXPENSES GO", trailing: FinanceFormat.amount(store.summary.expenses))

            CompositionBar(segments: categoryTotals.map { total in
                let percentage = FinanceFormat.percentage(total.total, of: store.summary.expenses)
                return CompositionSegment(
                    id: total.category.id,
                    value: total.total,
                    color: BancomerTheme.color(for: total.category),
                    label: percentage >= 9 ? "\(percentage)%" : "",
                    darkLabel: total.category == .housing || total.category == .food || total.category == .debt
                )
            })
            .padding(.top, 10)

            if categoryTotals.isEmpty {
                Text("Add an expense to see where the month is going.")
                    .emptyLedgerStyle()
            } else {
                VStack(spacing: 0) {
                    ForEach(categoryTotals) { total in
                        NavigationLink(value: total.category) {
                            CategoryRow(
                                category: total.category,
                                count: total.transactions.count,
                                amount: total.total,
                                percentage: FinanceFormat.percentage(total.total, of: store.summary.expenses)
                            )
                        }
                        .buttonStyle(.plain)
                        if total.id != categoryTotals.last?.id { Divider().overlay(BancomerTheme.hairline) }
                    }
                }
                .padding(.top, 7)
            }
        }
    }

    private var recurringSplit: some View {
        let summary = store.summary
        let recurringPercentage = FinanceFormat.percentage(summary.recurring, of: summary.expenses)
        let oneTimePercentage = FinanceFormat.percentage(summary.oneTime, of: summary.expenses)

        return LedgerSection {
            SectionHeading(title: "RECURRING VS ONE-TIME")

            CompositionBar(
                segments: summary.expenses == 0 ? [] : [
                    CompositionSegment(
                        id: "recurring",
                        value: summary.recurring,
                        color: BancomerTheme.color(for: .health),
                        label: recurringPercentage >= 16 ? "RECURRING \(recurringPercentage)%" : "",
                        darkLabel: false
                    ),
                    CompositionSegment(
                        id: "one-time",
                        value: summary.oneTime,
                        color: BancomerTheme.color(for: .debt),
                        label: oneTimePercentage >= 16 ? "ONE-TIME \(oneTimePercentage)%" : "",
                        darkLabel: true
                    ),
                ],
                height: 18
            )
            .padding(.top, 10)

            VStack(spacing: 0) {
                SplitRow(title: "Recurring", subtitle: "repeats monthly", amount: summary.recurring, percentage: recurringPercentage, color: BancomerTheme.color(for: .health))
                Divider().overlay(BancomerTheme.hairline)
                SplitRow(title: "One-time", amount: summary.oneTime, percentage: oneTimePercentage, color: BancomerTheme.color(for: .debt))
            }
            .padding(.top, 7)
        }
    }

    private var recentTransactions: some View {
        LedgerSection(bottomPadding: 92) {
            SectionHeading(title: "RECENT", trailing: "\(store.thisMonthTransactions.count) this month", subduedTrailing: true)
            if store.thisMonthTransactions.isEmpty {
                Text("Nothing recorded yet. Start with money in or money out.")
                    .emptyLedgerStyle()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(store.thisMonthTransactions.prefix(7).enumerated()), id: \.element.id) { index, transaction in
                        TransactionRow(transaction: transaction)
                        if index < min(store.thisMonthTransactions.count, 7) - 1 {
                            Divider().overlay(BancomerTheme.hairline)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
    }
}

private struct PrimaryFact: View {
    let title: String
    let amount: Decimal
    let positive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.custom("Libre Franklin", size: 10).weight(.bold))
                .tracking(0.7)
                .foregroundStyle(BancomerTheme.ink.opacity(0.62))
            Text("\(positive ? "+" : "−")\(FinanceFormat.amount(amount))")
                .font(.custom("Libre Franklin", size: 17).weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(positive ? BancomerTheme.positive : BancomerTheme.negative)
        }
    }
}

private struct LedgerSection<Content: View>: View {
    var bottomPadding: CGFloat = 4
    let content: Content

    init(bottomPadding: CGFloat = 4, @ViewBuilder content: () -> Content) {
        self.bottomPadding = bottomPadding
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.top, 17)
            .padding(.bottom, bottomPadding)
    }
}

struct SectionHeading: View {
    let title: String
    var trailing: String?
    var subduedTrailing = false

    var body: some View {
        HStack {
            Text(title)
                .font(.custom("Libre Franklin", size: 11).weight(.bold))
                .tracking(0.7)
                .foregroundStyle(BancomerTheme.inkDim)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.custom("Libre Franklin", size: subduedTrailing ? 11 : 13).weight(subduedTrailing ? .regular : .bold))
                    .monospacedDigit()
                    .foregroundStyle(subduedTrailing ? BancomerTheme.inkFaint : BancomerTheme.ink)
            }
        }
    }
}

private struct SplitRow: View {
    let title: String
    var subtitle: String?
    let amount: Decimal
    let percentage: Int
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 9, height: 9)
            HStack(spacing: 4) {
                Text(title).foregroundStyle(BancomerTheme.ink)
                if let subtitle {
                    Text(subtitle).font(.custom("Libre Franklin", size: 10)).foregroundStyle(BancomerTheme.inkFaint)
                }
            }
            Spacer()
            Text(FinanceFormat.amount(amount)).foregroundStyle(BancomerTheme.inkDim)
            Text("\(percentage)%").fontWeight(.semibold).frame(width: 36, alignment: .trailing)
        }
        .font(.custom("Libre Franklin", size: 12))
        .monospacedDigit()
        .padding(.vertical, 8)
    }
}

private extension View {
    func emptyLedgerStyle() -> some View {
        self
            .font(.custom("Libre Franklin", size: 11.5))
            .foregroundStyle(BancomerTheme.inkFaint)
            .padding(.top, 12)
    }
}
