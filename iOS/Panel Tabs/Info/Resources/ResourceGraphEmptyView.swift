import ScrechKit

struct ResourceGraphEmptyView: View {
    @Environment(PanelVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        ContentUnavailableView {
            Label("Server is stopped", systemImage: "bolt.slash")
        } description: {
            Text("Start the server to gather metrics")
        } actions: {
            Button("Start", systemImage: "play.fill", action: startServer)
            .buttonStyle(.glass)
            .tint(.green)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 140)
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.green.opacity(0.18), lineWidth: 1)
        }
    }
    
    private func startServer() {
        Task {
            await vm.changePower(.start)
        }
    }
}

#Preview {
    ResourceGraphEmptyView()
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
