import SwiftUI

struct TransactionRow: View {
    let transaction: LedgerTransaction

    private var metadata: String {
        [
            FinanceFormat.shortDate(transaction.date),
            transaction.category?.name,
            transaction.forWho.lowercased() == "me" ? nil : "for \(transaction.forWho)",
            transaction.recurring ? "recurring" : nil,
        ]
        .compactMap { $0 }
        .joined(separator: " · ")
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(transaction.category.map { BancomerTheme.color(for: $0) } ?? BancomerTheme.positive)
                .frame(width: 9, height: 9)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(.custom("Libre Franklin", size: 13))
                    .foregroundStyle(BancomerTheme.ink)
                    .lineLimit(1)
                Text(metadata)
                    .font(.custom("Libre Franklin", size: 10.5))
                    .foregroundStyle(BancomerTheme.inkFaint)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text("\(transaction.kind == .income ? "+" : "−")\(FinanceFormat.amount(transaction.amount))")
                .font(.custom("Libre Franklin", size: 13).weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(transaction.kind == .income ? BancomerTheme.positive : BancomerTheme.ink)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}
