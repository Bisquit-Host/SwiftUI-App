import ScrechKit

struct PowerSwitchToolbar: View {
    @Environment(PanelVM.self) private var vm
    
    @State private var confirmKill = false
    
    var body: some View {
        Menu {
            ControlGroup {
                AsyncButton("Start", systemImage: "play") {
                    await vm.changePower(.start)
                }
                
                AsyncButton("Restart", systemImage: "arrow.clockwise") {
                    await vm.changePower(.restart)
                }
                
                AsyncButton("Stop", systemImage: "pause") {
                    await vm.changePower(.stop)
                }
                
                Button("Kill", systemImage: "power", role: .destructive) {
                    confirmKill = true
                }
            }
        } label: {
            Image(systemName: "power")
                .semibold()
                .symbolEffect(.bounce, value: vm.stateColor)
                .foregroundStyle(vm.stateColor.gradient)
                .animation(.default, value: vm.stateColor)
        }
        .confirmationDialog("Perform kill action", isPresented: $confirmKill, titleVisibility: .visible) {
            AsyncButton("Kill", role: .destructive) {
                await vm.changePower(.kill)
            }
        }
    }
}

#Preview {
    PowerSwitchToolbar()
        .darkSchemePreferred()
        .environment(PanelVM(""))
}
