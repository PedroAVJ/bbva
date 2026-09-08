import SwiftUI

struct CompositionSegment: Identifiable {
    let id: String
    let label: String
    let amount: Double
    let color: Color
    let usesDarkLabel: Bool
}

struct CompositionBar: View {
    let segments: [CompositionSegment]

    private var total: Double {
        max(1, segments.reduce(0) { $0 + $1.amount })
    }

    var body: some View {
        GeometryReader { proxy in
            let gap: CGFloat = 2
            let gapWidth = gap * CGFloat(max(segments.count - 1, 0))
            let available = max(0, proxy.size.width - gapWidth)

            HStack(spacing: gap) {
                ForEach(segments) { segment in
                    ZStack {
                        Rectangle().fill(segment.color)
                        if !segment.label.isEmpty {
                            Text(segment.label)
                                .font(BBVATheme.sans(10, weight: .heavy))
                                .foregroundStyle(
                                    segment.usesDarkLabel ? Color(hex: "#08213D") : .white
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }
                    .frame(width: available * segment.amount / total, height: 26)
                }
            }
        }
        .frame(height: 26)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
