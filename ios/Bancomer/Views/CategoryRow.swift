import SwiftUI

struct CategoryRow: View {
    let category: ExpenseCategory
    let count: Int
    let amount: Decimal
    let percentage: Int
    var subtitle: String?
    var showsChevron = true

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(BancomerTheme.color(for: category))
                .frame(width: 9, height: 9)

            HStack(spacing: 4) {
                Text(category.name)
                    .foregroundStyle(BancomerTheme.ink)
                Text(subtitle ?? "\(count) tx")
                    .font(.custom("Libre Franklin", size: 10))
                    .foregroundStyle(BancomerTheme.inkFaint)
            }
            .font(.custom("Libre Franklin", size: 13))
            .lineLimit(1)

            Spacer(minLength: 8)

            Text(FinanceFormat.amount(amount))
                .foregroundStyle(BancomerTheme.inkDim)
            Text("\(percentage)%")
                .fontWeight(.semibold)
                .frame(width: 36, alignment: .trailing)
                .foregroundStyle(BancomerTheme.ink)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(BancomerTheme.inkFaint)
            }
        }
        .font(.custom("Libre Franklin", size: 12))
        .monospacedDigit()
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
