import SwiftUI

struct ServerListUpdateAlert: View {
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Section {
            if let url = URL(string: Endpoint.updateApp) {
                Button {
                    openURL(url)
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "link")
                        
                        Text("New Update Available")
                    }
                    .title3()
                }
            }
        }
    }
}

#Preview {
    List {
        ServerListUpdateAlert()
    }
}
