import SwiftUI

@main
struct BancomerApp: App {
    @StateObject private var store = LedgerStore()

    init() {
        Telemetry.start()
    }

    var body: some Scene {
        WindowGroup {
            DashboardView(store: store)
                .preferredColorScheme(.dark)
                .onAppear { Telemetry.log("app_ready") }
        }
    }
}
