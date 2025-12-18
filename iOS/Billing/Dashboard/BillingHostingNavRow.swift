import SwiftUI

struct BillingHostingNavRow: View {
    @Environment(BillingDashboardVM.self) private var vm
    
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
            HStack(spacing: 12) {
                GlassyIcon(category.icon, tint: tint)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.title)
                        .subheadline(.semibold)
                    
                    Text(category.description)
                        .footnote()
                        .secondary()
                }
                
                Spacer()
                
                Image(systemName: "chevron.forward")
                    .secondary()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}
