import SwiftUI

struct PanelOrnamentPower: View {
    @Environment(PanelVM.self) var vm: PanelVM
    
    private let showPowerButtons: Bool
    
    init(_ showPowerButtons: Bool) {
        self.showPowerButtons = showPowerButtons
    }
    
    var body: some View {
        if showPowerButtons {
            HStack {
                Button {
                    vm.changePower(.start)
                } label: {
                    Label("Start", systemImage: "play")
                }
                .disabled(vm.serverState != .offline)
                
                Button {
                    vm.changePower(.restart)
                } label: {
                    Label("Restart", systemImage: "arrow.triangle.2.circlepath")
                }
                
                Button {
                    vm.changePower(.stop)
                } label: {
                    Label("Stop", systemImage: "pause")
                }
                .disabled(vm.serverState == .stopping || vm.serverState == .offline)
                
                Capsule()
                    .fill(.primary)
                    .frame(width: 4, height: 32)
                
                Menu {
                    Button(role: .destructive) {
                        vm.changePower(.kill)
                    } label: {
                        Label("Kill", systemImage: "power")
                    }
                } label: {
                    Label("Kill", systemImage: "power")
                }
                .disabled(vm.serverState == .offline)
            }
            .padding(.bottom, 90)
        }
    }
}

#Preview {
    PanelOrnamentPower(true)
        .environment(PanelVM(""))
}
