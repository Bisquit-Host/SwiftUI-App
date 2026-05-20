import SwiftUI

struct BillingSectionCard<Content: View>: View {
    private let title: LocalizedStringKey?
    private let content: Content
    private let showsBackground: Bool
    
    init(
        _ title: LocalizedStringKey? = nil,
        showsBackground: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.showsBackground = showsBackground
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .headline()
            }
            
            content
        }
        .padding(16)
        .background {
            if showsBackground {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background.opacity(0.6))
            }
        }
        .overlay {
            if showsBackground {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.primary.opacity(0.04), lineWidth: 1)
            }
        }
    }
}

#Preview {
    BillingSectionCard("Preview") {
        Text("Content")
    }
    .padding()
    .darkSchemePreferred()
}
