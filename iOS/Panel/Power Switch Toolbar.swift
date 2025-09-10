import SwiftUI

struct PowerSwitchToolbar: View {
    @Environment(PanelVM.self) private var vm
    
    @State private var confirmKill = false
    
    var body: some View {
        Menu {
            ControlGroup {
                Button("Start", systemImage: "play") {
                    Task {
                        await vm.changePower(.start)
                    }
                }
                
                Button("Restart", systemImage: "arrow.clockwise") {
                    Task {
                        await vm.changePower(.restart)
                    }
                }
                
                Button("Stop", systemImage: "pause") {
                    Task {
                        await vm.changePower(.stop)
                    }
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
            Button("Kill", role: .destructive) {
                Task {
                    await vm.changePower(.kill)
                }
            }
        }
    }
}

#Preview {
    PowerSwitchToolbar()
        .environment(PanelVM(""))
}
