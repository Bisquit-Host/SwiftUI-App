import ScrechKit

struct PanelView: View {
    private var vm: PanelVM
    //    @StateObject private var fileVM: FileTabVM
    @EnvironmentObject private var settings: SettingsStorage
    
    private let id: String
    
    init(_ id: String,
         model: PanelVM = PanelVM("")
    ) {
        self.id = id
        self.vm = PanelVM(id)
        //        _fileVM = StateObject(wrappedValue: FileTabVM(id))
    }
    
    @AppStorage("selected_tab") private var selectedTab: Tab = .info
    
    private let tabs: [Tab] = [
        .info,
        .console,
        .files,
        .plugins,
        .backups,
        .schedules,
        .databases,
        .users,
        .allocations,
        .setup,
        .settings,
        .admin
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tabs, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Text(tab.rawValue)
                                .title2(.semibold, design: .rounded)
                                .padding(10)
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding()
            }
            
            switch selectedTab {
            case .files:
                FileTab(id)
                
            default:
                Spacer()
                
                Text("\(selectedTab.rawValue) is not yet availible")
                    .largeTitle()
                
                Spacer()
            }
        }
        .offset(y: -40)
        .task {
            vm.fetchServerDetails()
        }
        .onChange(of: id) {
            vm.fetchServerDetails()
        }
    }
}

#Preview {
    PanelView("")
        .environmentObject(SettingsStorage())
}
