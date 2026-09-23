import ScrechKit

struct ConsoleEmptyView: View {
    @Environment(PanelVM.self) private var panelVM
    
    var body: some View {
        ContentUnavailableView {
            Label("Console is empty", systemImage: "apple.terminal")
        } description: {
            Text("Launch the server to start receiving messages")
        } actions: {
            AsyncButton("🚀") {
                await panelVM.changePower(.start)
            }
        }
    }
}

#Preview {
    ConsoleEmptyView()
        .environment(PanelVM(""))
}
