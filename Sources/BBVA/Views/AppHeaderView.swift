import SwiftUI

struct AppHeaderView: View {
    let snapshot: DashboardSnapshot

    var body: some View {
        HStack(spacing: 8) {
            Text("BBVA")
                .font(BBVATheme.sans(12, weight: .bold))
                .foregroundStyle(.white.opacity(0.86))

            Spacer()

            HStack(spacing: 5) {
                Circle()
                    .fill(BBVATheme.coral)
                    .frame(width: 4, height: 4)

                Text(snapshot.dateLabel)
                    .font(BBVATheme.sans(11))
                    .monospacedDigit()
                    .foregroundStyle(BBVATheme.inkFaint)
            }
        }
        .padding(.leading, 84)
        .padding(.trailing, 14)
        .frame(height: 38)
        .background(BBVATheme.navy)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("BBVA, \(snapshot.dateLabel)")
    }
}
