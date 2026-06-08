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
            HStack(spacing: 12) {
                BigGlassyIcon(category.icon, tint: tint)
                
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
        .padding(10)
        .containerShape(.rect(cornerRadius: 12))
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }
}
