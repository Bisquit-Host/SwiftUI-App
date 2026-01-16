import SwiftUI

struct DashboardViewNavLinkLabel: View {
    private let title: LocalizedStringKey
    private let subtitle: LocalizedStringKey
    private let systemImage: String
    private let tint: Color
    private let showsBackground: Bool
    
    init(_ title: LocalizedStringKey, subtitle: LocalizedStringKey, systemImage: String, tint: Color, showsBackground: Bool = true) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
        self.showsBackground = showsBackground
    }
    
    var body: some View {
        let backgroundStyle = showsBackground ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.clear)
        
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
        .background(backgroundStyle, in: .rect(cornerRadius: 12))
        .foregroundStyle(.foreground)
    }
}
