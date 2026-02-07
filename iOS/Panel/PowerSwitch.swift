import SwiftUI

struct PowerSwitch: View {
    @Environment(PanelVM.self) private var vm
    
    @State private var confirmKill = false
    
    var body: some View {
        Menu {
#if os(visionOS)
            PowerSwitchButtons($confirmKill)
#else
            ControlGroup {
                PowerSwitchButtons($confirmKill)
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
            Button("Kill", role: .destructive, action: kill)
        }
    }
    
    private func kill() {
        Task {
            await vm.changePower(.kill)
        }
    }
}

#Preview {
    PowerSwitch()
        .darkSchemePreferred()
        .environment(PanelVM(""))
}
