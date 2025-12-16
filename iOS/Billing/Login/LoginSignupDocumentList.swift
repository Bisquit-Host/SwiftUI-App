import SwiftUI

struct LoginSignupDocumentList: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Please review and accept the documents below to create an account")
                .secondary()
                .footnote()
            
            VStack(spacing: 10) {
                ForEach(documents, id: \.title) { doc in
                    Button {
                        if let url = URL(string: doc.url) {
                            openURL(url)
                        }
                    } label: {
                        HStack {
                            Text(doc.title)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                                .secondary()
                        }
                    }
                    .secondary()
                    .frame(maxWidth: .infinity)
                    .loginTextField()
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
        }
        .navigationTitle("Documents")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }
}
