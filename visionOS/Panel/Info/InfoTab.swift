import ScrechKit
import Calagopus

struct InfoTab: View {
    private var logVM: LogVM
    @Environment(PanelVM.self) private var vm
    
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
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
            
            if let description = server.description, !description.isEmpty {
                Text(description)
                    .title3(.semibold)
                    .lineLimit(1)
            }
            
            Divider()
            
            LabeledContent("Uptime", value: Converter.millisecondsToTime(vm.uptime))
                .monospacedDigit()
            
            Divider()
            
            LabeledContent("Node", value: server.nodeName)
            
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
        .padding()
        .glassBackgroundEffect()
        .environment(PanelVM(""))
}
