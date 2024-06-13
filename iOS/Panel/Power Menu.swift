import ScrechKit

struct PowerSwitch: View {
    @Environment(PanelVM.self) private var vm
    
    @State private var confirmKill = false
    
    var body: some View {
        Menu {
            ControlGroup {
                MenuButton("Start", icon: "play") {
                    vm.changePower(.start)
                }
                
                MenuButton("Restart", icon: "arrow.clockwise") {
                    vm.changePower(.restart)
                }
                
                MenuButton("Stop", icon: "pause") {
                    vm.changePower(.stop)
                }
            }
            
            MenuButton("Kill", role: .destructive, icon: "power") {
                confirmKill = true
            }
        } label: {
            Image(systemName: "power")
                .title(.semibold)
                .symbolEffect(.bounce, value: vm.stateColor)
                .foregroundColor(vm.stateColor)
                .frame(width: 35, height: 35)
                .padding(10)
                .background(.ultraThinMaterial, in: .circle)
        }
        .confirmationDialog("Perform kill action", isPresented: $confirmKill, titleVisibility: .visible) {
            Button("Kill", role: .destructive) {
                vm.changePower(.kill)
            }
        }
    }
}

#Preview {
    PowerSwitch()
        .environment(PanelVM(""))
}
