import SwiftUI

struct AgentChatSettingsSheet: View {
    @State private var selectedTab = AgentChatSettingsTab.settings
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Settings", systemImage: "gearshape", value: .settings) {
                NavigationStack {
                    AgentChatSettings()
                }
            }
            
            Tab("History", systemImage: "clock.arrow.circlepath", value: .history) {
                NavigationStack {
                    AgentChatHistory()
                }
            }
        }
    }
}

#Preview {
    AgentChatSettingsSheet()
        .environment(AgentChatVM())
}
