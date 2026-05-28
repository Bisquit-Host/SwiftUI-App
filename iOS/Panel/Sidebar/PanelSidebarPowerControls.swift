import SwiftUI

struct PanelSidebarPowerControls: View {
    @Environment(PanelVM.self) private var vm
    
    @State private var confirmKill = false
    
    var body: some View {
        HStack(spacing: 8) {
            PanelSidebarPowerButton(title: "Start", systemImage: "play", tint: .green, action: start)
            PanelSidebarPowerButton(title: "Restart", systemImage: "arrow.clockwise", tint: .blue, action: restart)
            PanelSidebarPowerButton(title: "Stop", systemImage: "pause", tint: .red, action: stop)
            PanelSidebarPowerButton(title: "Kill", systemImage: "power", tint: Color(.sRGB, white: 0.25, opacity: 1), isFilled: true) {
                confirmKill = true
            }
        }
        .padding(.horizontal, 10)
        .confirmationDialog("Perform kill action", isPresented: $confirmKill, titleVisibility: .visible) {
            Button("Kill", role: .destructive, action: kill)
        }
    }
    
    private func start() {
        Task { await vm.changePower(.start) }
    }
    
    private func restart() {
        Task { await vm.changePower(.restart) }
    }
    
    private func stop() {
        Task { await vm.changePower(.stop) }
    }
    
    private func kill() {
        Task { await vm.changePower(.kill) }
    }
}

#Preview {
    PanelSidebarPowerControls()
        .padding()
        .darkSchemePreferred()
        .environment(PanelVM(""))
}
