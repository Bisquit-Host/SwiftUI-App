import SwiftUI
import PteroNet

struct PanelOrnamentInfo: View {
    @EnvironmentObject private var ornament: OrnamentProperty
    
    private let server: ServerAttributes
    private var showCustomizeButton = false
    
    init(_ server: ServerAttributes, showCustomizeButton: Bool = false) {
        self.showCustomizeButton = showCustomizeButton
        self.server = server
    }
    
    @State private var isHovered = false
    @State private var sheetOrnamentinfo = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if ornament.name {
                HStack {
                    Text("Name")
                    
                    Spacer()
                    
                    Text(server.name)
                }
            }
            
            if ornament.serverId {
                HStack {
                    Text("Server id")
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text(server.id)
                            .padding(8)
                            .glassBackgroundEffect()
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if ornament.status {
                HStack {
                    Text("Status")
                    
                    Spacer()
                    
                    Text("Running")
                        .foregroundStyle(.green)
                }
            }
            
            if ornament.uptime {
                HStack {
                    Text("Uptime")
                    
                    Spacer()
                    
                    Text("2d 12:12:12")
                }
            }
            
            if ornament.cpu {
                HStack {
                    Text("CPU")
                    
                    Spacer()
                    
                    Text("80%")
                }
            }
            
            if ornament.ram {
                HStack {
                    Text("RAM")
                    
                    Spacer()
                    
                    Text("80%")
                }
            }
            
            if ornament.ip {
                HStack {
                    Text("IP")
                    
                    Spacer()
                    
                    Text("1.2.3.4.43.34")
                }
            }
            
            if ornament.node {
                HStack {
                    Text("Node")
                    
                    Spacer()
                    
                    Text(server.node)
                }
            }
            
            if ornament.backups {
                HStack {
                    Text("Backups")
                    
                    Spacer()
                    
                    Text("10")
                }
            }
            
            if ornament.databases {
                HStack {
                    Text("Databases")
                    
                    Spacer()
                    
                    Text("10")
                }
            }
            
            if ornament.schedules {
                HStack {
                    Text("Schedules")
                    
                    Spacer()
                    
                    Text("10")
                }
            }
            
            if ornament.users {
                HStack {
                    Text("Users")
                    
                    Spacer()
                    
                    Text("10")
                }
            }
            
            //            if isHovered {
            if showCustomizeButton {
#warning("image")
                Button("Customize", systemImage: "") {
                    sheetOrnamentinfo = true
                }
            }
            //            }
        }
        .sheet($sheetOrnamentinfo) {
            OrnamentInfoSettings(server)
                .frame(width: 800, height: 600)
        }
        //        .hoverEffect()
        //        .onHover { hovering in
        //            print("onHover", hovering)
        //
        //            withAnimation {
        //                isHovered = hovering
        //            }
        //        }
        .frame(width: 250)
        .padding()
        .glassBackgroundEffect(in: .rect(cornerRadius: 32))
    }
}

#Preview {
    PanelOrnamentInfo(PreviewProp.serverAttributes)
}
