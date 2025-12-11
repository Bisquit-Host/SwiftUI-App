import SwiftUI

struct Card<Content: View, Trailing: View>: View {
    private let title: String
    private let trailing: Trailing
    private let content: Content
    
    init(
        _ title: LocalizedStringKey,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.trailing = trailing()
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .headline()
                
                Spacer()
                
                trailing
            }
            
            content
        }
        .padding(16)
        .background(.thinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.05))
        }
    }
}
