import SwiftUI
import TipKit

struct ServerListTips: View {
    @State private var apiKeyListVM = ApikeyVM()
    @Environment(ServerListVM.self) private var vm
    @Environment(SecurityTasks.self) private var securityTasks
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetAPIKeyList = false
    
    var body: some View {
        Group {
            if securityTasks.alertUnusedAPIKeys {
                TipView(TipUnusedAPIKeys()) {
                    if $0.id == "view" {
                        sheetAPIKeyList = true
                    }
                }
                .sheet($sheetAPIKeyList) {
                    NavigationStack {
                        ApikeyList()
                    }
                    .environment(apiKeyListVM)
                }
            }
            
            TipView(TipServerCardContextMenu())
            
            if vm.hasFrozenServers {
                TipView(TipSuspendedServer()) {
                    if $0.id == "open-billing" {
                        vm.showBilling = true
                    }
                }
            }
        }
        .tipBackground(.ultraThinMaterial.opacity(0.75))
        .tipCornerRadius(store.compactServerList ? 12 : 16)
        .scenePadding()
    }
}

#Preview {
    ServerListTips()
        .darkSchemePreferred()
        .environment(ServerListVM())
        .environment(SecurityTasks())
        .environmentObject(ValueStore())
}
