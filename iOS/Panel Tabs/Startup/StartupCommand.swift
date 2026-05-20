import ScrechKit

struct StartupCommand: View {
    @Environment(StartupVM.self) private var vm
    
    private var command: String {
        vm.startupCommand
    }
    
    var body: some View {
        Section("Startup Command") {
            Text(command)
                .caption2(design: .monospaced)
                .textSelection(.enabled)
        }
        .listRowBackground(Color.gray.opacity(0.2))
    }
}

#Preview {
    StartupCommand()
        .darkSchemePreferred()
        .environment(StartupVM(""))
}
