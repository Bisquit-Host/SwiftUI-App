import SwiftUI

struct ServerListUpdateButton: View {
    @Environment(UpdateChecker.self) private var updater
    @Environment(\.openURL) private var openUrl
    
    private let link = "https://apps.apple.com/app/bisquit-host/id1639409934"
    
    var body: some View {
        if updater.alertUpdate, let url = URL(string: link) {
            Button {
                openUrl(url)
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "link")
                    
                    Text("New Update Available")
                }
                .title3()
            }
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .padding(.bottom)
        }
    }
}

#Preview {
    ServerListUpdateButton()
        .environment(UpdateChecker())
}
