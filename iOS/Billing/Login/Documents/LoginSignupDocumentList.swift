import SwiftUI

struct LoginSignupDocumentList: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var hasAcceptedDocuments: Bool
    
    init(_ hasAcceptedDocuments: Binding<Bool>) {
        _hasAcceptedDocuments = hasAcceptedDocuments
    }
    
    private let documents: [(title: String, url: String)] = [
        ("Terms of Service", Endpoint.bisquitTerms),
        ("Privacy Policy", Endpoint.bisquitPrivacy),
        ("Data Processing Consent", Endpoint.bisquitConsent)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(documents, id: \.title) {
                LoginSignupDocumentCard(title: $0.title, url: $0.url)
            }
            
            Button {
                hasAcceptedDocuments = true
                dismiss()
            } label: {
                Text("Accept all documents")
                    .frame(maxWidth: .infinity)
            }
            .semibold()
            .rounded()
            .foregroundStyle(.foreground)
            .frame(minHeight: 50)
            .frame(maxWidth: .infinity)
            .glassEffect(.regular.tint(.green.opacity(0.3)))
            .overlay {
                Capsule()
                    .stroke(.green, lineWidth: 0.1)
            }
        }
        .navigationTitle("Documents")
        .navigationSubtitle("Please review and accept the documents below to create an account")
        .navigationBarTitleDisplayMode(.inline)
        .presentationDetents([.medium])
        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        .scenePadding()
    }
}
