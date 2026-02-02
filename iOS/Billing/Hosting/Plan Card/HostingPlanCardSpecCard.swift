import SwiftUI

struct HostingPlanCardSpecCard: View {
    private let icon, text: String
    private let category: BillingHostingCategory
    
    init(_ spec: (icon: String, text: String), in category: BillingHostingCategory) {
        self.icon = spec.icon
        self.text = spec.text
        self.category = category
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .footnote()
                .secondary()
            
            Text(text)
                .footnote()
                .monospacedDigit()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(category.tint.opacity(0.14), in: .capsule)
        .overlay {
            Capsule()
                .stroke(category.tint.opacity(0.35), lineWidth: 1)
        }
    }
}
