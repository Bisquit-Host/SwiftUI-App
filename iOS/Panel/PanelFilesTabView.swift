import ScrechKit

struct PanelFilesTabView: View {
    @Environment(PanelVM.self) private var panelVM
    @EnvironmentObject private var fileVM: FileTabVM
    
    private let serverID: String
    
    init(_ serverID: String) {
        self.serverID = serverID
    }
    
    var body: some View {
        FileTab(serverID)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ImagePlaygroundButton(fileVM.path)
                    
                    SFButton("folder.badge.plus") {
                        panelVM.alertNewFolder = true
                    }
                    
                    UploadMenu("")
                    PanelSettingsToolbarButton()
                }
            }
    }
}

