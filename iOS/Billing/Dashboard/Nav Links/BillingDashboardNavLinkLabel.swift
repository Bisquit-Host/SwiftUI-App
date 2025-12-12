import SwiftUI

struct BillingDashboardNavLinkLabel: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let systemImage: String
    let tint: Color
    
    init(_ title: LocalizedStringKey, subtitle: LocalizedStringKey, systemImage: String, tint: Color) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .largeTitle()
                .foregroundStyle(tint.gradient)
            
            VStack(alignment: .leading) {
                Text(title)
                    .semibold()
                
                Text(subtitle)
                    .footnote()
                    .secondary()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
        .foregroundStyle(.foreground)
    }
}
