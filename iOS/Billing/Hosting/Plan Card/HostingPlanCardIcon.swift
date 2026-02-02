import SwiftUI

struct HostingPlanCardIcon: View {
    private let category: BillingHostingCategory
    
    init(_ category: BillingHostingCategory) {
        self.category = category
    }
    
    var body: some View {
        Image(systemName: category.icon)
            .fontSize(18)
            .padding(10)
#if !os(visionOS)
            .glassEffect(.regular.tint(category.tint.opacity(0.25)), in: .circle)
#endif
            .foregroundStyle(category.tint)
    }
}
