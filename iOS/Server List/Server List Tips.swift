import SwiftUI
import TipKit

struct ServerListTips: View {
    @Environment(ServerListVM.self) private var vm
    
    var body: some View {
        TipView(TipServerCardContextMenu())
            .tipBackground(.ultraThinMaterial)
        
        if vm.hasFrozenServers {
            TipView(TipSuspendedServer()) { action in
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
