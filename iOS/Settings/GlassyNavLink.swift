import SwiftUI

struct GlassyNavLink<T: View>: View {
    private let title: LocalizedStringKey
    private let subtitle: LocalizedStringKey?
    private let icon: String
    private let tint: Color
    private let destination: () -> T
    
    init(_ title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, icon: String, tint: Color, destination: @escaping () -> T) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self.destination = destination
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                GlassyIcon(icon, tint: tint)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .subheadline(.semibold)
                    
                    if let subtitle {
                        Text(subtitle)
                            .footnote()
                            .secondary()
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .footnote()
                    .secondary()
            }
            .contentShape(.rect)
        }
        .foregroundStyle(.foreground)
    }
}
