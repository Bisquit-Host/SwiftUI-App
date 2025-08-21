import SwiftUI
import TipKit

struct ServerListTips: View {
    @Environment(ServerListVM.self) private var vm
    
    var body: some View {
        TipView(Tip_ServerCardContextMenu())
            .tipBackground(.ultraThinMaterial)
        
        if vm.hasFrozenServers {
            TipView(Tip_SuspendedServer()) { action in
                if action.id == "open-billing" {
                    vm.showBilling = true
                }
            }
            .tipBackground(.ultraThinMaterial)
            .tint(.primary)
        }
    }
}

#Preview {
    ServerListTips()
        .darkSchemePreferred()
        .environment(ServerListVM())
}
