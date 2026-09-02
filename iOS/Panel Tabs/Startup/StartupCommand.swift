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
    }
}

#Preview {
    StartupCommand()
        .darkSchemePreferred()
        .environment(StartupVM(""))
}
