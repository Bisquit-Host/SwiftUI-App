import SwiftUI
import TipKit

struct ServerListTips: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(SecurityTasks.self) private var securityTasks
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var securityTasks = securityTasks
        
        Group {
#if os(tvOS)
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
#elseif os(iOS)
            twoFaTip($securityTasks.alertTwoFA)
            
            suspendedServerTip()
#else
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
