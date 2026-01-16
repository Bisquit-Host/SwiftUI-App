import SwiftUI
import ScrechKit

struct DashboardViewNavLink<Destination: View>: View {
    private let title: LocalizedStringKey
    private let subtitle: LocalizedStringKey
    private let systemImage: String
    private let tint: Color
    @ViewBuilder private var destination: () -> Destination
    
    init(_ title: LocalizedStringKey, subtitle: LocalizedStringKey, systemImage: String, tint: Color, @ViewBuilder destination: @escaping () -> Destination) {
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
            DashboardViewNavLinkLabel(title, subtitle: subtitle, systemImage: systemImage, tint: tint)
        }
    }
}
