import SwiftUI
import TipKit

struct ServerListTips: View {
    @Environment(ServerListVM.self) private var vm
    
    var body: some View {
        TipView(TipServerCardContextMenu())
            .tipBackground(.ultraThinMaterial.opacity(0.75))
            .scenePadding()
        
        if vm.hasFrozenServers {
            TipView(TipSuspendedServer()) { action in
                if action.id == "open-billing" {
                    vm.showBilling = true
                }
            }
            .tipBackground(.ultraThinMaterial.opacity(0.75))
            .scenePadding()
        }
    }
}

#Preview {
    ServerListTips()
        .environment(ServerListVM())
}
