import ScrechKit

struct PanelView: View {
    private var vm: PanelVM
    private var fileVM: FileTabVM
    @EnvironmentObject private var settings: SettingsStorage
    
    private let id: String
    
    init(_ id: String,
         model: PanelVM = PanelVM("")
    ) {
        self.id = id
        self.vm = PanelVM(id)
        self.fileVM = FileTabVM(id)
    }
    
    var body: some View {
        TabView(selection: $settings.lastTabPanel) {
            if let server = vm.server {
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
            }
        }
        .padding()
        .onChange(of: id) {
            print("id Changed")
            fileVM.toolbarId = id
            fileVM.fetchFiles(id)
        }
        .onAppear {
            print("panel appear")
            fileVM.toolbarId = id
            fileVM.fetchFiles(id)
        }
    }
}

#Preview {
    PanelView("")
        .environmentObject(SettingsStorage())
}
