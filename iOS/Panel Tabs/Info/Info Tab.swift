import ScrechKit
import PteroNet

struct InfoTab: View {
    @State private var sectionsVM = PanelSectionVM()
    @State private var serverSettingsVM: ServerSettingsVM
    @State private var logVM: LogVM
    @State private var userVM: UsersVM
    @State private var subdomainVM: SubdomainVM
    @Environment(PanelVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        let id = server.id
        
        serverSettingsVM = ServerSettingsVM(id)
        logVM = LogVM(id)
        userVM = UsersVM(id)
        subdomainVM = SubdomainVM(id)
    }
    
    @State private var sheetCustomization = false
    @State private var selectedImage: UIImage? = nil
    private let width = UIScreen.main.bounds.width
    
    private var allocations: [AllocationAttributes] {
        server.relationships.allocations.data.map(\.attributes)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(sectionsVM.activeSections) { section in
                    switch section.name {
                    case "Resource Usage":
                        InfoTabResourceUsage(server)
                        
                    case "Allocations":
                        InfoTabAllocation(server)
                        
                    case "Users":
                        InfoTabUsers()
                            .environment(userVM)
                        
                    case "Logs":
                        InfoTabLogs()
                            .environment(logVM)
                        
                    case "Subdomains":
                        InfoTabSubdomains(allocations)
                            .environment(subdomainVM)
                        
                    case "Location":
                        MapSection(ip, node: server.node)
                        
                    default:
                        EmptyView()
                    }
                }
                
                CustomizeButton()
            }
            .padding(.horizontal, 4)
            .frame(width: width)
        }
        .background(BackgroundImage())
        .animation(.default, value: sectionsVM.activeSections)
        .sheet($sheetCustomization) {
            NavigationView {
                PanelSectionList()
                    .environment(sectionsVM)
            }
        }
        .task {
            let key = "background_image_fileName"
            
            if let fileName = UserDefaults.standard.string(forKey: key),
               let image = BackgroundImageHelper.loadImageFromDisk(fileName) {
                selectedImage = image
            }
            
            serverSettingsVM.serverName = server.name
            serverSettingsVM.serverDescription = server.description
            
            if !System.lowPowerMode {
                async let logs: () = logVM.fetchLogs(true)
                async let users: () = userVM.fetchUsers(true)
                async let subdomains: () = subdomainVM.fetchSubdomains()
                
                _ = await (logs, users, subdomains)
            }
        }
    }
    
    private func CustomizeButton() -> some View {
        Button {
            sheetCustomization = true
        } label: {
            Text("Customize & Reorder")
                .semibold()
                .secondary()
                .foregroundStyle(.foreground)
        }
        .padding(.top, 10)
    }
    
    private var ip: String? {
        let allocation = server.relationships.allocations.data.map(\.attributes).filter {
            $0.isDefault
        }.first
        
        guard let allocation else {
            return nil
        }
        
        if let ipAlias = allocation.ipAlias {
            return ipAlias
        } else {
            return allocation.ip
        }
    }
}

#Preview {
    InfoTab(PreviewProp.serverAttributes)
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
