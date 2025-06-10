import ScrechKit

struct PowerSwitch: View {
    @Environment(PanelVM.self) private var vm
    
    @State private var confirmKill = false
    
    var body: some View {
        Menu {
            ControlGroup {
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
                
                MenuButton("Kill", role: .destructive, icon: "power") {
                    confirmKill = true
                }
            }
        } label: {
            Image(systemName: "power")
                .title(.semibold)
                .symbolEffect(.bounce, value: vm.stateColor)
                .foregroundStyle(vm.stateColor.gradient)
                .animation(.default, value: vm.stateColor)
                .frame(35)
                .padding(10)
                .background(.ultraThinMaterial, in: .circle)
                .overlay {
                    Circle()
                        .stroke(.gray.opacity(0.25), lineWidth: 1)
                }
        }
        .hoverEffect(.lift)
        .confirmationDialog("Perform kill action", isPresented: $confirmKill, titleVisibility: .visible) {
            Button("Kill", role: .destructive) {
                Task {
                    await vm.changePower(.kill)
                }
            }
        }
    }
}

#Preview {
    PowerSwitch()
        .environment(PanelVM(""))
}
