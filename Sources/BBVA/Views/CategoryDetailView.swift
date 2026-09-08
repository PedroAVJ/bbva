import SwiftUI

struct CategoryDetailView: View {
    let snapshot: DashboardSnapshot
    let category: DashboardCategory
    let onBack: () -> Void

    private var percent: Int {
        Int(category.incomePercent(in: snapshot).rounded())
    }

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                detailHero
                detailBody
            }
        }
        .scrollIndicators(.hidden)
        .background(BBVATheme.background)
        .shadow(color: .black.opacity(0.5), radius: 14, x: -12, y: 0)
    }

    private var detailHero: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onBack) {
                Label("Back", systemImage: "chevron.left")
                    .font(BBVATheme.sans(13, weight: .bold))
                    .foregroundStyle(BBVATheme.aqua)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.leftArrow, modifiers: [.command])

            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: category.color))
                    .frame(width: 11, height: 11)
                Text(category.name.uppercased())
                    .font(BBVATheme.sans(12, weight: .bold))
                    .tracking(0.72)
                    .foregroundStyle(BBVATheme.aqua)
            }
            .padding(.top, 14)

            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text(FinanceFormat.whole(category.dailyMxn))
                    .font(BBVATheme.serif(44, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                Text("MXN per day · \(FinanceFormat.whole(category.monthlyMxn))/mo · \(percent)%")
                    .font(BBVATheme.sans(14))
                    .monospacedDigit()
                    .foregroundStyle(BBVATheme.heroSubtext)
                    .lineLimit(1)
            }
            .padding(.top, 6)

            Text(category.note)
                .font(BBVATheme.sans(12))
                .foregroundStyle(BBVATheme.heroSubtext)
                .padding(.top, 8)
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            LinearGradient(
                colors: [BBVATheme.navy, BBVATheme.heroEnd],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var detailBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            CompositionBar(segments: detailSegments)

            Text("\(category.name), zoomed · \(percent)% of income · \(FinanceFormat.whole(category.dailyMxn)) of your daily \(FinanceFormat.whole(snapshot.incomeDailyMxn))")
                .font(BBVATheme.sans(11))
                .monospacedDigit()
                .foregroundStyle(BBVATheme.inkFaint)
                .padding(.top, 6)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(Array(category.items.enumerated()), id: \.element.id) { index, item in
                    DetailItemRow(
                        category: category,
                        item: item,
                        shadeIndex: index
                    )
                }
            }

            if !category.footnote.isEmpty {
                Text(category.footnote)
                    .font(BBVATheme.sans(12))
                    .foregroundStyle(BBVATheme.inkDim)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 14)
    }

    private var detailSegments: [CompositionSegment] {
        let visibleTotal = max(1, category.items.reduce(0) { $0 + $1.monthlyMxn })
        return category.items.enumerated().map { index, item in
            let visiblePercent = item.monthlyMxn / visibleTotal * 100
            return CompositionSegment(
                id: item.id,
                label: visiblePercent >= 9 ? "\(Int(item.categoryPercent(in: category).rounded()))%" : "",
                amount: item.monthlyMxn,
                color: .shaded(hex: category.color, index: index, count: category.items.count),
                usesDarkLabel: index >= max(1, category.items.count / 2)
            )
        }
    }
}

private struct DetailItemRow: View {
    let category: DashboardCategory
    let item: DashboardItem
    let shadeIndex: Int

    private var hasTopDivider: Bool {
        item.id != category.items.first?.id
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Circle()
                .fill(Color.shaded(hex: category.color, index: shadeIndex, count: category.items.count))
                .frame(width: 9, height: 9)
                .alignmentGuide(.firstTextBaseline) { dimensions in
                    dimensions[VerticalAlignment.center]
                }

            Text(item.name)
                .font(BBVATheme.sans(13))
                .foregroundStyle(BBVATheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)

            (
                Text("\(FinanceFormat.whole(item.monthlyMxn))/mo · ")
                    .font(BBVATheme.sans(12))
                    .foregroundColor(BBVATheme.inkDim)
                + Text("\(FinanceFormat.whole(item.dailyMxn))/day")
                    .font(BBVATheme.sans(12, weight: .bold))
                    .foregroundColor(BBVATheme.ink)
            )

            Text("\(Int(item.categoryPercent(in: category).rounded()))%")
                .font(BBVATheme.sans(12, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(BBVATheme.ink)
                .frame(width: 34, alignment: .trailing)
        }
        .padding(.vertical, 8)
        .overlay(alignment: .top) {
            if hasTopDivider {
                Rectangle().fill(BBVATheme.line).frame(height: 1)
            }
        }
    }
}
