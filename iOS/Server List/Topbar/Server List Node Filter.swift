import SwiftUI

struct ServerListNodeFilter: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var settings: ValueStorage
    
    private var nodes: [String] {
        Array(Set(vm.servers.map(\.node)))
    }
    
    var body: some View {
        if settings.adminMode {
            Menu {
                Button {
                    withAnimation {
                        vm.displayedNode = ""
                    }
                } label: {
                    if vm.displayedNode.isEmpty {
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
                        let nodeName = node.capitalized
                        
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
