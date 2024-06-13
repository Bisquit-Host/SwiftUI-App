import ScrechKit

struct PowerSwitch: View {
    @Environment(PanelVM.self) private var vm
    
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
#warning("Add confirmation")
                vm.changePower(.kill)
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
    }
}

#Preview {
    PowerSwitch()
        .environment(PanelVM(""))
}
