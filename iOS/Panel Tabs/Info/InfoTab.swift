import ScrechKit
import PteroNet

struct InfoTab: View {
    @State private var sectionsVM = PanelSectionVM()
    @State private var serverSettingsVM: ServerSettingsVM
    @State private var logVM: LogVM
    @State private var userVM: UsersVM
    @State private var subdomainVM: SubdomainVM
    
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
    
    private var allocations: [AllocationAttributes] {
        server.relationships.allocations.data.map(\.attributes)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(sectionsVM.activeSections) {
                    switch $0.name {
                    case "Resource Usage":
                        InfoTabResources(server)
                        
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
                        MapSection(ip, node: server.node, allocations: server.relationships.allocations.data)
                        
                    default:
                        EmptyView()
                    }
                }
                
                InfoTabCustomizationButton($sheetCustomization)
            }
            .padding(.horizontal, 4)
        }
        .background(BackgroundImage())
        .animation(.default, value: sectionsVM.activeSections)
        .sheet($sheetCustomization) {
            NavigationStack {
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
                async let logs:       () = logVM.fetchLogs(true)
                async let users:      () = userVM.fetchUsers(true)
                async let subdomains: () = subdomainVM.fetchSubdomains()
                
                _ = await (logs, users, subdomains)
            }
        }
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
        .darkSchemePreferred()
        .environment(PanelVM(""))
}
