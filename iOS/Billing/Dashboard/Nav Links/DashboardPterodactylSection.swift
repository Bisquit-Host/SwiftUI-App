import SwiftUI

struct DashboardPterodactylSection: View {
    @Environment(NavState.self) private var nav
    
    var body: some View {
        BillingSectionCard("Manage", showsBackground: false) {
            VStack(spacing: 12) {
                Button {
                    nav.navigate(.toServerListParent)
                } label: {
                    DashboardCardLabel("Pterodactyl", description: "Game Servers & Bots", icon: "externaldrive", tint: .purple)
                }
                .buttonStyle(.plain)
                .padding(10)
                .containerShape(.rect(cornerRadius: 12))
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
            }
        }
    }
}
