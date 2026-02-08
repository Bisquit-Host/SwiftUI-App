import SwiftUI

struct PowerSwitchToolbar: View {
    @Environment(PanelVM.self) private var vm
    
    @State private var confirmKill = false
    
    var body: some View {
        Menu {
            ControlGroup {
                Button("Start", systemImage: "play", action: start)
                Button("Restart", systemImage: "arrow.clockwise", action: restart)
                Button("Stop", systemImage: "pause", action: stop)
                
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
            Button("Kill", role: .destructive, action: kill)
        }
    }
    
    private func kill() {
        Task {
            await vm.changePower(.kill)
        }
    }
    
    private func start() {
        Task {
            await vm.changePower(.start)
        }
    }
    
    private func restart() {
        Task {
            await vm.changePower(.restart)
        }
    }
    
    private func stop() {
        Task {
            await vm.changePower(.stop)
        }
    }
}

#Preview {
    PowerSwitchToolbar()
        .darkSchemePreferred()
        .environment(PanelVM(""))
}
