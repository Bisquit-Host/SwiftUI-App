import SwiftUI

struct ServerListUpdateButton: View {
    @Environment(SecurityTasks.self) private var securityTasks
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        if securityTasks.alertUpdate, let url = URL(string: Endpoint.updateApp) {
            Button {
                openURL(url)
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
        .darkSchemePreferred()
        .environment(SecurityTasks())
}
