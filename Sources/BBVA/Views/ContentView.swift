import AppKit
import SwiftUI

struct ContentView: View {
    @Bindable var store: DashboardStore

    var body: some View {
        VStack(spacing: 0) {
            AppHeaderView(snapshot: store.snapshot)

            GeometryReader { proxy in
                ZStack {
                    HomeView(snapshot: store.snapshot, onOpen: store.open)
                        .offset(x: store.selectedCategory == nil ? 0 : -proxy.size.width * 0.28)
                        .allowsHitTesting(store.selectedCategory == nil)
                        .accessibilityHidden(store.selectedCategory != nil)

                    if let category = store.selectedCategory {
                        CategoryDetailView(
                            snapshot: store.snapshot,
                            category: category,
                            onBack: store.closeDetail
                        )
                        .transition(.move(edge: .trailing))
                        .zIndex(2)
                    }
                }
                .clipped()
                .animation(
                    NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
                        ? nil
                        : BBVATheme.pushAnimation,
                    value: store.selectedCategoryID
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BBVATheme.background)
        .foregroundStyle(BBVATheme.ink)
        .ignoresSafeArea(.container, edges: .top)
    }
}
