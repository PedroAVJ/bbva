import SwiftUI

struct DailyNetStrip: View {
    let values: [Double]

    private var maxAbsoluteValue: Double {
        max(1, values.map(abs).max() ?? 1)
    }

    var body: some View {
        GeometryReader { proxy in
            let gap: CGFloat = 3
            let count = max(values.count, 1)
            let width = max(1, (proxy.size.width - gap * CGFloat(count - 1)) / CGFloat(count))

            HStack(spacing: gap) {
                ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                    DailyNetColumn(value: value, maxAbsoluteValue: maxAbsoluteValue)
                        .frame(width: width, height: 56)
                }
            }
        }
        .frame(height: 56)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Last 14 days daily net")
        .accessibilityValue(values.map(FinanceFormat.signedWhole).joined(separator: ", "))
    }
}

private struct DailyNetColumn: View {
    let value: Double
    let maxAbsoluteValue: Double

    private var barHeight: CGFloat {
        max(3, round(26 * sqrt(abs(value) / maxAbsoluteValue)))
    }

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(BBVATheme.line)
                .frame(height: 1)
                .offset(y: 28)

            RoundedRectangle(cornerRadius: 2)
                .fill(value >= 0 ? BBVATheme.teal : BBVATheme.coral)
                .frame(height: barHeight)
                .offset(y: value >= 0 ? 28 - barHeight : 29)
        }
        .frame(height: 56, alignment: .top)
    }
}
