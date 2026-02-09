import SwiftUI
import WebKit

struct SupportWikiView: View {
    var body: some View {
        WebView(url: URL(string: Endpoint.bisquitWiki)!)
            .navigationTitle("Wiki")
    }
}

#Preview {
    NavigationStack {
        SupportWikiView()
    }
    .darkSchemePreferred()
}
