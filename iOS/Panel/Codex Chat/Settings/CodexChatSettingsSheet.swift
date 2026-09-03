import SwiftUI

struct CodexChatSettingsSheet: View {
    @State private var selectedTab = CodexChatSettingsTab.settings
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Settings", systemImage: "gearshape", value: .settings) {
                NavigationStack {
                    CodexChatSettings()
                }
            }
            
            Tab("History", systemImage: "clock.arrow.circlepath", value: .history) {
                NavigationStack {
                    CodexChatHistory()
                }
            }
        }
    }
}

#Preview {
    CodexChatSettingsSheet()
        .environment(CodexChatVM())
}
