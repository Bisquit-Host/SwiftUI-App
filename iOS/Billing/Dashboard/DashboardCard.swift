import SwiftUI

struct DashboardCard: View {
    @Environment(DashboardVM.self) private var vm
    
    private let category: BillingHostingCategory
    private let tint: Color
    
    init(_ category: BillingHostingCategory, tint: Color) {
        self.category = category
        self.tint = tint
    }
    
    var body: some View {
        NavigationLink {
            HostingPlanList(category)
                .environment(vm)
        } label: {
            DashboardCardLabel(category.title, description: category.description, icon: category.icon, tint: tint)
                .padding(10)
                .dashboardButtonCardBackground()
        }
        .buttonStyle(.plain)
    }
}
