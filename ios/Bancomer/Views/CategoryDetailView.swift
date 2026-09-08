import SwiftUI

struct CategoryDetailView: View {
    @ObservedObject var store: LedgerStore
    let category: ExpenseCategory

    private var transactions: [LedgerTransaction] { store.transactions(for: category) }
    private var total: Decimal { transactions.reduce(Decimal.zero) { $0 + $1.amount } }
    private var recurring: Decimal {
        transactions.filter(\.recurring).reduce(Decimal.zero) { $0 + $1.amount }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                VStack(alignment: .leading, spacing: 0) {
                    CompositionBar(segments: transactions.enumerated().map { index, transaction in
                        let percentage = FinanceFormat.percentage(transaction.amount, of: total)
                        return CompositionSegment(
                            id: transaction.id.uuidString,
                            value: transaction.amount,
                            color: BancomerTheme.color(for: category).opacity(1 - min(Double(index) * 0.11, 0.44)),
                            label: percentage >= 9 ? "\(percentage)%" : "",
                            darkLabel: category == .housing || category == .food || category == .debt
                        )
                    })

                    Text("\(category.name), zoomed · \(FinanceFormat.percentage(total, of: store.summary.expenses))% of expenses this month")
                        .font(.custom("Libre Franklin", size: 10.5))
                        .foregroundStyle(BancomerTheme.inkFaint)
                        .padding(.top, 6)

                    VStack(spacing: 0) {
                        ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                            TransactionRow(transaction: transaction)
                            if index < transactions.count - 1 { Divider().overlay(BancomerTheme.hairline) }
                        }
                    }
                    .padding(.top, 6)

                    Text(category.note)
                        .font(.custom("Libre Franklin", size: 11.5))
                        .foregroundStyle(BancomerTheme.inkFaint)
                        .padding(.top, 12)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
        }
        .scrollIndicators(.hidden)
        .background(BancomerTheme.app.ignoresSafeArea())
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Circle().fill(BancomerTheme.color(for: category)).frame(width: 11, height: 11)
                Text(category.name.uppercased())
                    .font(.custom("Libre Franklin", size: 11).weight(.bold))
                    .tracking(0.7)
                    .foregroundStyle(BancomerTheme.aqua)
            }
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text("−\(FinanceFormat.amount(total))")
                    .font(.custom("Source Serif 4", size: 44).weight(.semibold))
                    .monospacedDigit()
                Text("MXN this month · \(FinanceFormat.percentage(total, of: store.summary.expenses))% of expenses")
                    .font(.custom("Libre Franklin", size: 12))
                    .foregroundStyle(BancomerTheme.ink.opacity(0.64))
            }
            .padding(.top, 6)
            Text("recurring \(FinanceFormat.amount(recurring)) · one-time \(FinanceFormat.amount(total - recurring)) · \(transactions.count) transaction\(transactions.count == 1 ? "" : "s")")
                .font(.custom("Libre Franklin", size: 11.5))
                .foregroundStyle(BancomerTheme.ink.opacity(0.64))
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(BancomerTheme.hero)
    }
}
