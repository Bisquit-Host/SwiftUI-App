import SwiftUI

struct DiscoverDocuments: View {
    @State private var showTOS = false
    @State private var showPriacyPolicy = false
    
    var body: some View {
        Menu {
            Button("ToS", systemImage: "text.document") {
                showTOS = true
            }
            
            Button("Privacy Policy", systemImage: "text.document") {
                showPriacyPolicy = true
            }
        } label: {
            DiscoverCardLabel("Documents", image: .docBlue)
        }
        .safariCover($showTOS, url: "https://bisquit.host/terms.pdf")
        .safariCover($showPriacyPolicy, url: "https://bisquit.host/policy.pdf")
    }
}

#Preview {
    DiscoverDocuments()
}
