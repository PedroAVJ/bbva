import SwiftUI

struct CategoryRow: View {
    let snapshot: DashboardSnapshot
    let category: DashboardCategory
    let action: () -> Void

    private var percent: Int {
        Int(category.incomePercent(in: snapshot).rounded())
    }

    private var hasTopDivider: Bool {
        category.id != snapshot.categories.first?.id
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Circle()
                    .fill(Color(hex: category.color))
                    .frame(width: 9, height: 9)
                    .alignmentGuide(.firstTextBaseline) { dimensions in
                        dimensions[VerticalAlignment.center]
                    }

                categoryLabelView

                Spacer(minLength: 0)

                Text("\(FinanceFormat.whole(category.monthlyMxn))/mo · \(FinanceFormat.whole(category.dailyMxn))/day")
                    .font(BBVATheme.sans(12, weight: category.id == "yours" ? .bold : .regular))
                    .tracking(-0.36)
                    .monospacedDigit()
                    .foregroundStyle(category.id == "yours" ? BBVATheme.teal : BBVATheme.inkDim)
                    .lineLimit(1)

                Text("\(percent)%")
                    .font(BBVATheme.sans(12, weight: category.id == "yours" ? .bold : .semibold))
                    .monospacedDigit()
                    .foregroundStyle(category.id == "yours" ? BBVATheme.teal : BBVATheme.ink)
                    .frame(width: 30, alignment: .trailing)

                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(BBVATheme.inkFaint)
                    .frame(width: 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .padding(.vertical, 7)
            .overlay(alignment: .top) {
                if hasTopDivider {
                    Rectangle()
                        .fill(category.id == "yours" ? BBVATheme.teal : BBVATheme.line)
                        .frame(height: category.id == "yours" ? 2 : 1)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(category.name), \(FinanceFormat.whole(category.monthlyMxn)) per month, \(percent) percent")
        .accessibilityHint("Open category details")
    }

    private var categoryLabel: Text {
        let primary = Text(category.name)
            .font(BBVATheme.sans(13, weight: category.id == "yours" ? .heavy : .regular))
            .foregroundColor(BBVATheme.ink)
        guard !category.subtitle.isEmpty else { return primary }
        return primary
            + Text(" \(category.subtitle)")
                .font(BBVATheme.sans(11))
                .foregroundColor(BBVATheme.inkFaint)
    }

    @ViewBuilder
    private var categoryLabelView: some View {
        if category.id == "other" {
            VStack(alignment: .leading, spacing: 0) {
                Text("Other fixed")
                    .font(BBVATheme.sans(13))
                    .foregroundColor(BBVATheme.ink)
                + Text(" services · subs ·")
                    .font(BBVATheme.sans(11))
                    .foregroundColor(BBVATheme.inkFaint)

                Text("software")
                    .font(BBVATheme.sans(11))
                    .foregroundStyle(BBVATheme.inkFaint)
            }
            .frame(width: 150, alignment: .leading)
        } else {
            categoryLabel
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
