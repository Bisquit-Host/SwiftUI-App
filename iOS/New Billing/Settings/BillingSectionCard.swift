import SwiftUI

struct BillingSectionCard<Content: View>: View {
    private let title: String
    private let content: Content
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .headline()
            
            content
        }
        .padding(16)
        .background(.background.opacity(0.6), in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.primary.opacity(0.04), lineWidth: 1)
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
