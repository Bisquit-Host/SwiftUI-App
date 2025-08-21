import ScrechKit
import PteroNet

struct InfoTab: View {
    private var logVM: LogVM
    @Environment(PanelVM.self) private var vm
    @Environment(\.openURL) private var openUrl
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.logVM = LogVM(server.id)
    }
    
    @State private var sheetLogs = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(server.name)
                    .largeTitle()
                
                Spacer()
                
                Button(server.id) {
                    Pasteboard.copy(server.id)
                    SystemAlert.copied()
                }
                .padding(8)
            }
            
            if !server.description.isEmpty {
                Text(server.description)
                    .title3(.semibold)
                    .lineLimit(1)
            }
            
            Divider()
            
            ListParam("Uptime", param: millisecondsToTime(vm.uptime))
                .monospacedDigit()
            
            Divider()
            
            ListParam("Node", param: server.node)
            
            Divider()
            
            HStack {
                Text("Recent Activity")
                
                Spacer()
                
                Button("View") {
                    sheetLogs = true
                }
            }
        }
        .padding(30)
        .glassBackgroundEffect()
        .frame(width: 650)
        .sheet($sheetLogs) {
            LogList()
                .environment(logVM)
        }
        .task {
            if !System.lowPowerMode {
                await logVM.fetchLogs(true)
            }
        }
    }
}

#Preview {
    InfoTab(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .padding()
        .glassBackgroundEffect()
        .environment(PanelVM(""))
}
