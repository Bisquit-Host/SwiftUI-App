import SwiftUI

struct ServerListNodeFilter: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var settings: ValueStorage
    
    var body: some View {
        Menu("Nodes") {
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
            
            ForEach(vm.nodes, id: \.self) { node in
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
        }
    }
}

#Preview {
    ServerListNodeFilter()
        .environment(ServerListVM())
        .environmentObject(ValueStorage())
    
}
