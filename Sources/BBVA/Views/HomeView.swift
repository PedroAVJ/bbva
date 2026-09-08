import SwiftUI

struct HomeView: View {
    let snapshot: DashboardSnapshot
    let onOpen: (DashboardCategory) -> Void

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                BalanceHeroView(snapshot: snapshot)
                DailyNetSection(snapshot: snapshot)
                IncomeSection(snapshot: snapshot, onOpen: onOpen)
            }
        }
        .scrollIndicators(.hidden)
        .background(BBVATheme.background)
    }
}

private struct DailyNetSection: View {
    let snapshot: DashboardSnapshot

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                SectionTitle("Last 14 days · daily net")
                Spacer()
                Text(snapshot.outlierNote)
                    .font(BBVATheme.sans(11))
                    .monospacedDigit()
                    .foregroundStyle(BBVATheme.inkFaint)
            }

            DailyNetStrip(values: snapshot.dailyNetsMxn)
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 6)
    }
}

private struct IncomeSection: View {
    let snapshot: DashboardSnapshot
    let onOpen: (DashboardCategory) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                SectionTitle("Where the income goes")
                Spacer()
                (
                    Text(FinanceFormat.whole(snapshot.incomeMonthlyMxn))
                        .font(BBVATheme.sans(13, weight: .bold))
                        .foregroundColor(BBVATheme.ink)
                    + Text(" · \(FinanceFormat.whole(snapshot.incomeDailyMxn))/day")
                        .font(BBVATheme.sans(13))
                        .foregroundColor(BBVATheme.inkDim)
                )
                .monospacedDigit()
            }
            .padding(.bottom, 10)

            CompositionBar(
                segments: snapshot.categories.map {
                    CompositionSegment(
                        id: $0.id,
                        label: segmentLabel(for: $0),
                        amount: $0.monthlyMxn,
                        color: Color(hex: $0.color),
                        usesDarkLabel: $0.id != "health" && $0.id != "ai"
                    )
                }
            )

            VStack(spacing: 0) {
                ForEach(snapshot.categories) { category in
                    CategoryRow(snapshot: snapshot, category: category) {
                        onOpen(category)
                    }
                }
            }
            .padding(.top, 12)
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }

    private func segmentLabel(for category: DashboardCategory) -> String {
        let percent = Int(category.incomePercent(in: snapshot).rounded())
        guard percent >= 9 || category.id == "other" else { return "" }
        switch category.id {
        case "debt": return "DEBT \(percent)%"
        case "ai": return "AI \(percent)%"
        case "yours": return "YOURS \(percent)%"
        case "other": return ""
        default: return "\(percent)%"
        }
    }
}

struct SectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title.uppercased())
            .font(BBVATheme.sans(11, weight: .heavy))
            .tracking(0.88)
            .foregroundStyle(BBVATheme.inkDim)
    }
}
