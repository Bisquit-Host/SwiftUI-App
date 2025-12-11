import ScrechKit

struct BillingDashboardNavLink<Destination: View>: View {
    let title: LocalizedStringKey
    let subtitle: String
    let systemImage: String
    let tint: Color
    @ViewBuilder var destination: () -> Destination
    
    init(_ title: LocalizedStringKey, subtitle: String, systemImage: String, tint: Color, destination: @escaping () -> Destination) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
        self.destination = destination
    }
    
    var body: some View {
        NavigationLink {
            destination()
        } label: {
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
        }
        .foregroundStyle(.foreground)
    }
}
