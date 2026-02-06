import ScrechKit

struct PanelConsoleTabView: View {
    @Environment(ConsoleVM.self) private var consoleVM
    
    private let serverID: String
    
    init(_ serverID: String) {
        self.serverID = serverID
    }
    
    var body: some View {
        ConsoleTab(serverID)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    SFButton("bold.italic.underline") {
                        consoleVM.inspectorPresented = true
                    }
                    
                    PanelSettingsToolbarButton()
                }
            }
    }
}

