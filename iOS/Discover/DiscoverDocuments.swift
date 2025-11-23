import SwiftUI

struct DiscoverDocuments: View {
    @State private var showTerms = false
    @State private var showPriacyPolicy = false
    
    var body: some View {
        Menu {
            Button("Terms of Service", systemImage: "text.document") {
                showTerms = true
            }
            
            Button("Privacy Policy", systemImage: "hand.raised") {
                showPriacyPolicy = true
            }
        } label: {
            DiscoverCardLabel("Documents", image: .docBlue)
        }
        .safariCover($showTerms, url: Endpoint.bisquitTerms)
        .safariCover($showPriacyPolicy, url: Endpoint.bisquitPrivacy)
    }
}

#Preview {
    DiscoverDocuments()
        .darkSchemePreferred()
}
