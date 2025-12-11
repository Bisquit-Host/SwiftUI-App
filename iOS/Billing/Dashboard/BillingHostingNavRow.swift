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
            BillingHostingPlansView(defaultCategory: category)
                .environment(vm)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .frame(32)
                    .glassEffect(.regular.tint(tint.opacity(0.2)), in: .rect(cornerRadius: 10))
                    .foregroundStyle(tint)
                
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
