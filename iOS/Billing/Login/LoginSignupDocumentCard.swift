import SwiftUI

struct LoginSignupDocumentCard: View {
    @Environment(\.openURL) private var openURL
    
    let title: String
    let url: String
    @Binding var acceptedDocumentTitles: Set<String>
    
    private var isAccepted: Bool {
        acceptedDocumentTitles.contains(title)
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Button {
                if isAccepted {
                    acceptedDocumentTitles.remove(title)
                } else {
                    acceptedDocumentTitles.insert(title)
                }
            } label: {
                Image(systemName: isAccepted ? "checkmark.circle.fill" : "circle")
                    .title3()
            }
            
            Button {
                guard let url = URL(string: url) else { return }
                openURL(url)
            } label: {
                HStack {
                    Text(title)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right.square")
                }
            }
        }
        .foregroundStyle(.foreground)
        .padding(.horizontal)
        .frame(height: 50)
        .background(.primary.opacity(0.04), in: .capsule)
        .overlay {
            Capsule()
                .stroke(.primary.opacity(0.05), lineWidth: 1)
        }
    }
}

#Preview {
    LoginSignupDocumentCard(title: "Terms of Service", url: Endpoint.bisquitTerms, acceptedDocumentTitles: .constant([]))
        .darkSchemePreferred()
}
