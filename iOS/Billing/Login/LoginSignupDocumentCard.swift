import SwiftUI

struct LoginSignupDocumentCard: View {
    @Environment(\.openURL) private var openURL
    
    let title: String
    let url: String
    
    var body: some View {
        HStack(spacing: 10) {
            Button {
                guard let url = URL(string: url) else { return }
                openURL(url)
            } label: {
                HStack {
                    Text(title)
                    
                    Spacer()
                    
                    Image(systemName: "text.document")
                        .secondary()
                }
            }
        }
        .foregroundStyle(.foreground)
        .padding(.horizontal)
        .frame(height: 50)
        .background(.ultraThinMaterial, in: .capsule)
        .overlay {
            Capsule()
                .stroke(.primary, lineWidth: 0.1)
        }
    }
}

#Preview {
    LoginSignupDocumentCard(title: "Terms of Service", url: Endpoint.bisquitTerms)
        .darkSchemePreferred()
}
