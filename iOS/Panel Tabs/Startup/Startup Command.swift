import ScrechKit

struct StartupCommand: View {
    @Environment(StartupVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private var command: String {
        store.rawStartupCommand ? vm.rawStartupCommand : vm.startupCommand
    }
    
    var body: some View {
        Section {
            if vm.rawStartupCommand != vm.startupCommand {
                Toggle("Raw", isOn: $store.rawStartupCommand)
            }
            
            Text(command)
                .caption2(design: .monospaced)
                .textSelection(.enabled)
                .animation(.default, value: store.rawStartupCommand)
        } header: {
            HStack {
                Text("Startup Command")
                
                Spacer()
                
                SFButton("document.on.document") {
                    Pasteboard.copy(command)
                    SystemAlert.copied()
                }
                .foregroundStyle(.foreground)
            }
        }
        .listRowBackground(Color.gray.opacity(0.2))
    }
}

#Preview {
    StartupCommand()
        .environment(StartupVM(""))
        .environmentObject(ValueStore())
}
