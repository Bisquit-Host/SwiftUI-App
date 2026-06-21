import SwiftUI
import Calagopus

struct OrnamentInfoSettings: View {
    @EnvironmentObject private var ornament: OrnamentValueStore
    @Environment(\.dismiss) private var dismiss
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack {
                PanelOrnamentInfo(server)
                
                Button("Done", systemImage: "checkmark") {
                    dismiss()
                }
                .padding(.top, 50)
            }
            
            Spacer()
            
            List {
                Toggle("Name", isOn: $ornament.name)
                Toggle("Server id", isOn: $ornament.serverId)
                Toggle("Status", isOn: $ornament.status)
                Toggle("Uptime", isOn: $ornament.uptime)
                Toggle("CPU", isOn: $ornament.cpu)
                Toggle("RAM", isOn: $ornament.ram)
                Toggle("IP", isOn: $ornament.ip)
                Toggle("Node", isOn: $ornament.node)
                Toggle("Backups", isOn: $ornament.backups)
                Toggle("Databases", isOn: $ornament.databases)
                Toggle("Schedules", isOn: $ornament.schedules)
                Toggle("Users", isOn: $ornament.users)
            }
            .scrollIndicators(.never)
            .padding(.vertical)
            .frame(width: 320)
        }
    }
}

#Preview {
    OrnamentInfoSettings(PreviewProp.serverAttributes)
        .environmentObject(OrnamentValueStore())
}
