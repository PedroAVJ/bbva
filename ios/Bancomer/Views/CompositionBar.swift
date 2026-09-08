import SwiftUI

struct CompositionSegment: Identifiable {
    let id: String
    let value: Decimal
    let color: Color
    let label: String
    let darkLabel: Bool
}

struct CompositionBar: View {
    let segments: [CompositionSegment]
    var height: CGFloat = 26

    private var total: Decimal {
        segments.reduce(Decimal.zero) { $0 + $1.value }
    }

    var body: some View {
        GeometryReader { proxy in
            if segments.isEmpty || total == 0 {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.white.opacity(0.02))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(BancomerTheme.hairline, lineWidth: 1)
                    }
            } else {
                HStack(spacing: 2) {
                    ForEach(segments) { segment in
                        let ratio = NSDecimalNumber(decimal: segment.value / total).doubleValue
                        Text(segment.label)
                            .font(.custom("Libre Franklin", size: 10).weight(.bold))
                            .fontDesign(.rounded)
                            .foregroundStyle(segment.darkLabel ? BancomerTheme.titlebar : BancomerTheme.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                            .frame(width: max(0, proxy.size.width * ratio - 2), height: height)
                            .background(segment.color)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            }
        }
        .frame(height: height)
        .accessibilityElement(children: .combine)
    }
}
