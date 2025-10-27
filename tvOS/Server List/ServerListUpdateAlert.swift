import SwiftUI

struct ServerListUpdateAlert: View {
    @Environment(\.openURL) private var openUrl
    
    var body: some View {
        Section {
            if let url = URL(string: "https://apps.apple.com/app/bisquit-host/id1639409934") {
                Button {
                    openUrl(url)
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
