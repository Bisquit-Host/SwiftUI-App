import ScrechKit

struct PanelView: View {
    @EnvironmentObject private var store: ValueStore
    private var vm: PanelVM
    private var fileVM: FileTabVM
    
    private let id: String
    @State private var selectedTab: PanelTab = .info
    
    init(_ id: String) {
        self.id = id
        vm = PanelVM(id)
        fileVM = FileTabVM(id)
    }
    
    var body: some View {
        Group {
            if let server = vm.server {
                TabView(selection: $selectedTab) {
                InfoTab(server)
                    .tag(PanelTab.info)
                
                Console()
                    .tag(PanelTab.console)
                
                FileTab(id)
                    .environmentObject(fileVM)
                    .tag(PanelTab.files)
                }
            } else {
                ProgressView()
            }
        }
        .environment(vm)
        .onAppear {
            switch store.panelTab {
            case .info, .console, .files:
                selectedTab = store.panelTab
                
            default:
                store.panelTab = .info
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            store.panelTab = newValue
        }
        .task {
            await vm.fetchServerDetails()
            
            if let data = await vm.consoleDetails() {
                vm.connectWebSocket(data)
            }
            
            if !System.lowPowerMode {
                await fileVM.fetchFiles()
            }
        }
        .onDisappear {
            vm.disconnectWebSocket()
        }
    }
}

#Preview {
    PanelView("")
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
