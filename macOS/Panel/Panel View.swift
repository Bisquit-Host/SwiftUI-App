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
    
    //    @AppStorage("last_panel_tab") var lastPanelTab: Tabs = .info
    
    @State private var selectedTab: Tab = .info
    
    private let tabs: [Tab] = [
        .info,
        .console,
        .backups,
        .files,
        .users,
        .schedules,
        .databases,
        .allocations,
        .settings
    ]
    
    private let gradient = Gradient(colors: [.orange, .yellow])
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tabs, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Text(tab.rawValue)
                                .title3(.semibold, design: .rounded)
                                .padding(5)
                                .background(gradient.opacity(0.7), in: .rect(cornerRadius: 5))
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding()
            }
            
            switch selectedTab {
            case .files:
                FileTab(id)
                    .environmentObject(fileVM)
                
            default:
                Spacer()
            }
        }
#if os(macOS)
        .background {
            ZStack {
                BackgroundBlur()
                
                Color.orange.opacity(0.1)
            }
        }
#endif
        .task {
            vm.fetchServerDetails()
            fileVM.toolbarId = id
            fileVM.fetchFiles()
        }
        .onChange(of: id) {
            vm.fetchServerDetails()
            fileVM.toolbarId = id
            fileVM.fetchFiles()
        }
    }
}

#Preview {
    PanelView("")
        .environmentObject(SettingsStorage())
}
