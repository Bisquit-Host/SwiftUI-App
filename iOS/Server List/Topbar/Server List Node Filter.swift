import SwiftUI

struct ServerListNodeFilter: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    private let nodes: [Node] = [
        .swift,
        .invictus,
        .renaissance,
        .exodus
    ]
    
    var body: some View {
        if settings.adminMode {
            Menu {
                Button {
                    withAnimation {
                        vm.displayedNode = .all
                    }
                } label: {
                    if vm.displayedNode == .all {
                        Label("All", systemImage: "checkmark")
                    } else {
                        Text("All")
                    }
                }
                
                Divider()
                
                ForEach(nodes, id: \.self) { node in
                    Button {
                        withAnimation {
                            vm.displayedNode = node
                        }
                    } label: {
                        let nodeName = node.rawValue.capitalized
                        
                        if vm.displayedNode == node {
                            Label(nodeName, systemImage: "checkmark")
                        } else {
                            Text(nodeName)
                        }
                    }
                }
            } label: {
                Text("Nodes")
            }
        }
    }
}
