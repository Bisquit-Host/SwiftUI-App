import SwiftUI
import TipKit

struct ServerListTips: View {
#if !os(tvOS)
    @State private var apiKeyListVM = ApikeyVM()
#endif
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
                } label: {
                    unusedAPIKeysTip($securityTasks.alertUnusedAPIKeys)
                }
            }
            
            if TipEnable2FA().status == .available {
                Button {
                    TipEnable2FA().invalidate(reason: .actionPerformed)
                } label: {
                    twoFaTip($securityTasks.alertTwoFA)
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
            unusedAPIKeysTip($securityTasks.alertUnusedAPIKeys)
                .sheet($sheetAPIKeyList) {
                    NavigationStack {
                        ApikeyList()
                    }
                    .environment(apiKeyListVM)
                }
            
            twoFaTip($securityTasks.alertTwoFA)
            
            suspendedServerTip()
#endif
        }
        .tipBackground(.ultraThinMaterial.opacity(0.75))
        .tipCornerRadius(store.compactServerList ? 12 : 16)
#if os(iOS)
        .scenePadding(.horizontal)
        .padding(.vertical, 5)
#elseif !os(macOS)
        .padding(.horizontal, 25)
#endif
    }
    
    private func unusedAPIKeysTip(_ isPresented: Binding<Bool>) -> some View {
        TipView(TipUnusedAPIKeys(), isPresented: isPresented) {
            if $0.id == "view" {
                sheetAPIKeyList = true
            }
        }
    }
    
    private func twoFaTip(_ isPresented: Binding<Bool>) -> some View {
        TipView(TipEnable2FA(), isPresented: isPresented)
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
