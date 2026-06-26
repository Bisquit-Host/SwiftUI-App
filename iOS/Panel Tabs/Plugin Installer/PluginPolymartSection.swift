import SwiftUI

struct PluginPolymartSection: View {
    @Environment(PluginInstallerVM.self) private var vm
    
    let handlePolymartAction: () -> Void
    
    var body: some View {
        BillingSectionCard("Polymart account", showsBackground: false) {
            if vm.isLoadingPolymart {
                HStack(spacing: 10) {
                    ProgressView()
                    
                    Text("Loading account state")
                        .secondary()
                }
            } else {
                Text(vm.isPolymartLinked ? "Connected" : "Not connected")
                    .subheadline(.semibold)
                
                Button {
                    handlePolymartAction()
                } label: {
                    Label(
                        vm.isPolymartLinked ? "Disconnect Polymart" : "Connect Polymart",
                        systemImage: vm.isPolymartLinked ? "link.badge.minus" : "link.badge.plus"
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(vm.isPolymartLinked ? .red : .blue)
            }
        }
    }
}
