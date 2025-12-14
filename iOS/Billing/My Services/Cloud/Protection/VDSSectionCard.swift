import SwiftUI

struct VDSSectionCard<Content: View>: View {
    private let title: LocalizedStringKey?
    private let spacing: CGFloat
    private let content: Content
    private let primaryButton: AnyView?
    
    init(
        _ title: LocalizedStringKey? = nil,
        spacing: CGFloat = 12,
        @ViewBuilder content: () -> Content,
        @ViewBuilder primaryButton: () -> some View = { EmptyView() }
    ) {
        self.title = title
        self.spacing = spacing
        self.content = content()
        
        let button = primaryButton()
        self.primaryButton = button is EmptyView ? nil : AnyView(button)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if let title {
                HStack {
                    Text(title)
                        .headline()
                    
                    Spacer()
                    
                    if let primaryButton {
                        primaryButton
                    }
                }
            }
            
            content
        }
        .padding(16)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.primary.opacity(0.04), lineWidth: 1)
        }
    }
}

#Preview {
    VDSSectionCard("Preview") {
        Text("Content")
    }
    .padding()
    .darkSchemePreferred()
}
