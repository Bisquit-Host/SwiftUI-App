import SwiftUI

struct PowerSwitchButtons: View {
    @Environment(PanelVM.self) private var vm
    
    @Binding private var confirmKill: Bool
    
    init(_ confirmKill: Binding<Bool>) {
        _confirmKill = confirmKill
    }
    
    var body: some View {
        Group {
            Button("Start", systemImage: "play", action: start)
            Button("Restart", systemImage: "arrow.clockwise", action: restart)
            Button("Stop", systemImage: "pause", action: stop)
            
            Section {
                Button("Kill", systemImage: "power", role: .destructive) {
                    confirmKill = true
                }
            }
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
