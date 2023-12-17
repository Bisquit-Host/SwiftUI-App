import ScrechKit
import PteroNet

struct Panel_View: View {
    @StateObject private var fileVM: FileTabVM
    @EnvironmentObject private var settings: Settings_Storage
    private var model: PanelModel
    
    private let id: String
    
    init(
        _ id: String,
        model: PanelModel = PanelModel("")
    ) {
        self.id = id
        self.model = PanelModel(id)
        _fileVM = StateObject(wrappedValue: FileTabVM(id))
    }
    
    var body: some View {
        TabView(selection: $settings.lastTabPanel) {
            if let server = model.server {
                StatsTab(server)
                    .tag(Tab.info)
                    .tabItem {
                        Text("Stats")
                    }
                
                FileTab(id)
                    .environmentObject(fileVM)
                    .tag(Tab.fileManager)
                    .tabItem {
                        Text("Files")
                    }
                
                //            DataTab(id, backup_limit: limits.backups, database_limit: limits.databases)
                //                .tag(Tab.backup)
                //                .tabItem {
                //                    Text("Data")
                //                }
            }
        }
    }
}

#Preview {
    Panel_View("")
        .environmentObject(Settings_Storage())
}
