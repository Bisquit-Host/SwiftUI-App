import ScrechKit

struct PowerSwitchButtons: View {
    @Environment(PanelVM.self) private var vm
    
    @Binding private var confirmKill: Bool
    
    init(_ confirmKill: Binding<Bool>) {
        _confirmKill = confirmKill
    }
    
    var body: some View {
        Group {
            AsyncButton("Start", systemImage: "play") {
                await vm.changePower(.start)
            }
            
            AsyncButton("Restart", systemImage: "arrow.clockwise") {
                await vm.changePower(.restart)
            }
            
            AsyncButton("Stop", systemImage: "pause") {
                await vm.changePower(.stop)
            }
            
            Section {
                Button("Kill", systemImage: "power", role: .destructive) {
                    confirmKill = true
                }
            }
        }
    }
}
