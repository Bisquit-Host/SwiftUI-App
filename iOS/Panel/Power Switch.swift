import ScrechKit

struct PowerSwitch: View {
    @Environment(PanelVM.self) private var vm
    
    @State private var confirmKill = false
    
    var body: some View {
        Menu {
#if os(visionOS)
            powerMenuButtons()
#else
            ControlGroup {
                powerMenuButtons()
            }
#endif
        } label: {
            Image(systemName: "power")
                .semibold()
                .symbolEffect(.bounce, value: vm.stateColor)
                .foregroundStyle(vm.stateColor.gradient)
                .animation(.default, value: vm.stateColor)
        }
        .confirmationDialog("Perform kill action", isPresented: $confirmKill, titleVisibility: .visible) {
            Button("Kill", role: .destructive) {
                Task {
                    await vm.changePower(.kill)
                }
            }
        }
    }
    
    private func powerMenuButtons() -> some View {
        Group {
            MenuButton("Start", icon: "play") {
                Task {
                    await vm.changePower(.start)
                }
            }
            
            MenuButton("Restart", icon: "arrow.clockwise") {
                Task {
                    await vm.changePower(.restart)
                }
            }
            
            MenuButton("Stop", icon: "pause") {
                Task {
                    await vm.changePower(.stop)
                }
            }
            
            Section {
                MenuButton("Kill", role: .destructive, icon: "power") {
                    confirmKill = true
                }
            }
        }
    }
}

#Preview {
    PowerSwitch()
        .environment(PanelVM(""))
        .darkSchemePreferred()
}
