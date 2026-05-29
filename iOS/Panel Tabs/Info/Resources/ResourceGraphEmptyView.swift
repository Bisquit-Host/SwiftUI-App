import SwiftUI

struct ResourceGraphEmptyView: View {
    @Environment(PanelVM.self) private var vm
    
    var body: some View {
        ContentUnavailableView {
            Label("Server is stopped", systemImage: "bolt.slash")
        } description: {
            Text("Start the server to gather metrics")
        } actions: {
            Button(action: startServer) {
                Image(systemName: "play.fill")
                    .padding(5)
            }
            .buttonStyle(.glass)
            .tint(.green)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
    }
    
    private func startServer() {
        Task {
            await vm.changePower(.start)
        }
    }
}

#Preview {
    ResourceGraphEmptyView()
}
