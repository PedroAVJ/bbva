import SwiftUI

struct BalanceHeroView: View {
    let snapshot: DashboardSnapshot

    private var balanceColor: Color {
        snapshot.balanceMxn < 0 ? BBVATheme.coral : BBVATheme.teal
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("YOUR BALANCE")
                .font(BBVATheme.sans(12, weight: .bold))
                .tracking(0.72)
                .foregroundStyle(BBVATheme.aqua)

            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text(FinanceFormat.signedWhole(snapshot.balanceMxn))
                    .font(BBVATheme.serif(54, weight: .semibold))
                    .tracking(-1.35)
                    .monospacedDigit()
                    .foregroundStyle(balanceColor)

                Text("MXN · +\(FinanceFormat.whole(snapshot.dailyCreditMxn)) lands daily")
                    .font(BBVATheme.sans(14))
                    .tracking(-0.14)
                    .monospacedDigit()
                    .foregroundStyle(BBVATheme.heroSubtext)
                    .lineLimit(1)
            }
            .frame(height: 54, alignment: .bottom)
            .padding(.top, 2)

            Text("spent today: \(FinanceFormat.whole(snapshot.spentTodayMxn)) · typical slack: \(FinanceFormat.whole(snapshot.typicalSlackDailyMxn))/day")
                .font(BBVATheme.sans(12))
                .monospacedDigit()
                .foregroundStyle(BBVATheme.heroSubtext)
                .padding(.top, 8)

            recoveryText
                .font(BBVATheme.sans(12))
                .lineSpacing(4)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BBVATheme.coral.opacity(0.10))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(BBVATheme.coral.opacity(0.35), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.top, 12)
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
        .padding(.bottom, 27)
        .background {
            LinearGradient(
                colors: [BBVATheme.navy, BBVATheme.heroEnd],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .accessibilityElement(children: .combine)
    }

    private var recoveryText: Text {
        Text("\(FinanceFormat.whole(abs(snapshot.balanceMxn))) behind.")
            .foregroundColor(balanceColor)
            .bold()
        + Text(" Even in ").foregroundColor(BBVATheme.inkDim)
        + Text("\(snapshot.recovery.noSpendDays) days")
            .foregroundColor(BBVATheme.ink)
            .bold()
        + Text(" spending nothing — or by ").foregroundColor(BBVATheme.inkDim)
        + Text(FinanceFormat.shortDate(snapshot.recovery.typicalPaceDate))
            .foregroundColor(BBVATheme.ink)
            .bold()
        + Text(" at typical pace. A cheap week beats a perfect day.")
            .foregroundColor(BBVATheme.inkDim)
    }
}
