import SwiftUI

struct HostingPlanCardIcon: View {
    private let category: BillingHostingCategory
    
    init(_ category: BillingHostingCategory) {
        self.category = category
    }
    
    var body: some View {
        Image(systemName: category.icon)
            .fontSize(18)
            .foregroundStyle(category.tint)
    }
}
