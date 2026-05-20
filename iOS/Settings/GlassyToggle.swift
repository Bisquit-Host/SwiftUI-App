import SwiftUI

struct GlassyToggle: View {
    private let title: LocalizedStringKey
    private let subtitle: LocalizedStringKey?
    private let icon: String
    private let tint: Color
    @Binding private var isOn: Bool
    
    init(_ title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, icon: String, tint: Color, isOn: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        _isOn = isOn
    }
    
    var body: some View {
        HStack(spacing: 12) {
            GlassyIcon(icon, tint: tint)
            
            VStack(alignment: .leading) {
                Text(title)
                    .subheadline(.semibold)
                
                if let subtitle {
                    Text(subtitle)
                        .secondary()
                        .footnote()
                }
            }
            
            Spacer()
            
            Toggle(isOn: $isOn) {
                EmptyView()
            }
            .labelsHidden()
        }
    }
}
