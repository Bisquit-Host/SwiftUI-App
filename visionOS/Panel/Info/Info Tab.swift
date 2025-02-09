import ScrechKit
import PteroNet

struct InfoTab: View {
    private var logVM: LogVM
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
                    UIPasteboard.general.string = server.id
                    
                    SystemAlert.copied()
                }
                .padding(8)
            }
            
            Text(server.description)
                .title3(.semibold)
                .lineLimit(1)
            
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
                logVM.fetchLogs(true)
            }
        }
    }
}

#Preview {
    InfoTab(PreviewProperty.serverAttributes)
        .padding()
        .glassBackgroundEffect()
}
