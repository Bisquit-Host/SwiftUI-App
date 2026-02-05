import SwiftUI

struct VersionChangerPickerCard<Content: View>: View {
    private let title: LocalizedStringKey
    private let icon: String
    private let tint: Color
    private let content: Content
    
    init(
        title: LocalizedStringKey,
        icon: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.tint = tint
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            GlassyIcon(icon, tint: tint)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .subheadline(.semibold)
                
                content
            }
            
            Spacer()
        }
    }
}

#Preview {
    VersionChangerPickerCard(title: "Type", icon: "shippingbox.fill", tint: .indigo) {
        Picker("Type", selection: .constant("Paper")) {
            Text("Paper")
                .tag("Paper")
            
            Text("Purpur")
                .tag("Purpur")
        }
        .pickerStyle(.menu)
    }
    .padding()
    .darkSchemePreferred()
}
