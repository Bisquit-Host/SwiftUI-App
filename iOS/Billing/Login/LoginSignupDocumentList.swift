import SwiftUI

struct LoginSignupDocumentList: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var hasAcceptedDocuments: Bool
    @State private var acceptedDocumentTitles = Set<String>()
    
    init(_ hasAcceptedDocuments: Binding<Bool>) {
        _hasAcceptedDocuments = hasAcceptedDocuments
    }
    
    private let documents: [(title: String, url: String)] = [
        ("Terms of Service", Endpoint.bisquitTerms),
        ("Privacy Policy", Endpoint.bisquitPrivacy),
        ("Data Processing Consent", Endpoint.bisquitConsent)
    ]
    
    private var allAccepted: Bool {
        acceptedDocumentTitles.count == documents.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 10) {
                ForEach(documents, id: \.title) {
                    LoginSignupDocumentCard(title: $0.title, url: $0.url, acceptedDocumentTitles: $acceptedDocumentTitles)
                }
            }
            
            Button {
                hasAcceptedDocuments = true
                dismiss()
            } label: {
                Text("Accept documents")
                    .frame(maxWidth: .infinity)
            }
            .semibold()
            .rounded()
            .foregroundStyle(.foreground)
            .frame(minHeight: 50)
            .frame(maxWidth: .infinity)
            .glassEffect()
            .disabled(!allAccepted)
        }
        .navigationTitle("Documents")
        .navigationSubtitle("Please review and accept the documents below to create an account")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .onAppear {
            if hasAcceptedDocuments {
                acceptedDocumentTitles = Set(documents.map(\.title))
            }
        }
        .onChange(of: acceptedDocumentTitles) { _, _ in
            hasAcceptedDocuments = allAccepted
        }
    }
}
