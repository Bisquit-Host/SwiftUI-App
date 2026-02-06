import ScrechKit
import PteroNet

struct InfoTab: View {
    @State private var sectionsVM = PanelSectionVM()
    @State private var serverSettingsVM: ServerSettingsVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        serverSettingsVM = ServerSettingsVM(server.id)
    }
    
    @State private var sheetCustomization = false
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(sectionsVM.activeSections) {
                    switch $0.name {
                    case "Resource Graphs":
                        InfoTabResourceGraphs(server)
                        
                    case "Allocations":
                        InfoTabAllocation(server)
                        
                    case "Users":
                        InfoTabUsers(server.id)
                        
                    case "Logs":
                        InfoTabLogs(server.id)
                        
                    case "Subdomains":
                        if server.eggId == 34 {
                            InfoTabSubdomains(server)
                        }
                        
                    case "Location":
                        MapSection(server)
                        
                    default:
                        EmptyView()
                    }
                }
                
                InfoTabCustomizationButton($sheetCustomization)
            }
            .padding(.horizontal, 4)
        }
        .scrollIndicators(.never)
        .background(BackgroundImage())
        .animation(.default, value: sectionsVM.activeSections)
        .task {
            await fetchData()
        }
        .sheet($sheetCustomization) {
            NavigationStack {
                PanelSectionList()
                    .environment(sectionsVM)
            }
        }
    }
    
    private func fetchData() async {
        let key = "background_image_fileName"
        
        if let fileName = UserDefaults.standard.string(forKey: key),
           let image = BackgroundImageHelper.loadImageFromDisk(fileName) {
            selectedImage = image
        }
        
        serverSettingsVM.serverName = server.name
        serverSettingsVM.serverDescription = server.description
    }
}

#Preview {
    InfoTab(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(PanelVM(""))
}
