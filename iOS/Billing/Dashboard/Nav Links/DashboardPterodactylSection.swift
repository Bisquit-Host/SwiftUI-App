import SwiftUI

struct DashboardPterodactylSection: View {
    @Environment(NavState.self) private var nav
    
    var body: some View {
        BillingSectionCard("Manage", showsBackground: false) {
            VStack(spacing: 12) {
                Button {
                    nav.navigate(.toServerListParent)
                } label: {
                    DashboardCardLabel("Calagopus", description: "Game Servers & Bots", icon: "externaldrive", tint: .purple)
                        .padding(10)
                        .dashboardButtonCardBackground()
                }
                .buttonStyle(.plain)
            }
        }
    }
}
