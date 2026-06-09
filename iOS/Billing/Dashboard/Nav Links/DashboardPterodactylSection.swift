import SwiftUI

struct DashboardPterodactylSection: View {
    @Environment(NavState.self) private var nav
    
    var body: some View {
        BillingSectionCard("Manage", showsBackground: false) {
            VStack(spacing: 12) {
                Button {
                    nav.navigate(.toServerListParent)
                } label: {
                    DashboardNavLinkLabel("Pterodactyl", subtitle: "Game Servers & Bots", systemImage: "externaldrive", tint: .purple)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
