import Observation

@MainActor
@Observable
final class DashboardStore {
    private(set) var snapshot: DashboardSnapshot
    var selectedCategoryID: String?

    init(dataSource: any DashboardDataSource = SQLiteDashboardDataSource()) {
        do {
            snapshot = try dataSource.loadSnapshot()
        } catch {
            fatalError("Unable to load the BBVA dashboard: \(error.localizedDescription)")
        }
    }

    var selectedCategory: DashboardCategory? {
        guard let selectedCategoryID else { return nil }
        return snapshot.categories.first { $0.id == selectedCategoryID }
    }

    func open(_ category: DashboardCategory) {
        selectedCategoryID = category.id
    }

    func closeDetail() {
        selectedCategoryID = nil
    }
}
