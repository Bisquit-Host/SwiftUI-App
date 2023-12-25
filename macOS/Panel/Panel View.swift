import ScrechKit

struct PanelView: View {
    private var vm: PanelVM
    @EnvironmentObject private var settings: SettingsStorage
    
    private let id: String
    
    init(_ id: String,
         model: PanelVM = PanelVM("")
    ) {
        self.id = id
        self.vm = PanelVM(id)
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
                                .foregroundStyle(selectedTab == tab ? .yellow : .primary)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding()
            }
            
            Group {
                switch selectedTab {
                case .files:
                    FileTab(id)
                    
                case .users:
                    UserList(id)
                        .environment(UsersVM(id))
                    
                default:
                    Spacer()
                    
                    Text("\(selectedTab.rawValue) will be availible soon...")
                        .largeTitle()
                    
                    Spacer()
                }
            }
            .id(id)
        }
        .offset(y: -30)
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
