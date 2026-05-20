import ScrechKit

struct DashboardNavLink<Destination: View>: View {
    private let title: LocalizedStringKey
    private let subtitle: LocalizedStringKey
    private let systemImage: String
    private let tint: Color
    private let showsBackground: Bool
    @ViewBuilder private var destination: () -> Destination
    
    init(_ title: LocalizedStringKey, subtitle: LocalizedStringKey, systemImage: String, tint: Color, showsBackground: Bool = true, @ViewBuilder destination: @escaping () -> Destination) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
        self.showsBackground = showsBackground
        self.destination = destination
    }
    
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            DashboardNavLinkLabel(title, subtitle: subtitle, systemImage: systemImage, tint: tint, showsBackground: showsBackground)
        }
    }
}
