import SwiftUI
import TipKit

struct ServerListTips: View {
    @State private var apiKeyListVM = ApikeyVM()
    @Environment(ServerListVM.self) private var vm
    @Environment(SecurityTasks.self) private var securityTasks
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetAPIKeyList = false
    
    var body: some View {
        @Bindable var securityTasks = securityTasks
        
        Group {
#if os(tvOS)
            if TipUnusedAPIKeys().status == .available {
                Button {
                    sheetAPIKeyList = true
                    TipUnusedAPIKeys().invalidate(reason: .actionPerformed)
                } label: {
                    unusedAPIKeysTip($securityTasks.alertUnusedAPIKeys)
                }
            }
            
            if TipServerCardContextMenu().status == .available {
                Button {
                    TipServerCardContextMenu().invalidate(reason: .tipClosed)
                } label: {
                    serverCardContextMenuTip()
                }
            }
            
            if TipSuspendedServer().status == .available {
                Button {
                    vm.showBilling = true
                    TipSuspendedServer().invalidate(reason: .actionPerformed)
                } label: {
                    suspendedServerTip()
                }
            }
#else
            unusedAPIKeysTip(isPresented: $securityTasks.alertUnusedAPIKeys)
                .sheet($sheetAPIKeyList) {
                    NavigationStack {
                        ApikeyList()
                    }
                    .environment(apiKeyListVM)
                }
            
            serverCardContextMenuTip()
            suspendedServerTip()
#endif
        }
        .tipBackground(.ultraThinMaterial.opacity(0.75))
        .tipCornerRadius(store.compactServerList ? 12 : 16)
#if os(visionOS) || os(tvOS)
        .padding(.horizontal, 25)
#else
        .scenePadding()
#endif
    }
    
    private func unusedAPIKeysTip(_ isPresented: Binding<Bool>) -> some View {
        TipView(TipUnusedAPIKeys(), isPresented: isPresented) {
            if $0.id == "view" {
                sheetAPIKeyList = true
                TipUnusedAPIKeys().invalidate(reason: .actionPerformed)
            }
        }
    }
    
    private func serverCardContextMenuTip() -> some View {
        TipView(TipServerCardContextMenu())
    }
    
    private func suspendedServerTip() -> some View {
        TipView(TipSuspendedServer(), isPresented: .constant(vm.hasFrozenServers)) {
            if $0.id == "open-billing" {
                vm.showBilling = true
                TipSuspendedServer().invalidate(reason: .actionPerformed)
            }
        }
    }
}

#Preview {
    ServerListTips()
        .darkSchemePreferred()
        .environment(ServerListVM())
        .environment(SecurityTasks())
        .environmentObject(ValueStore())
}
