import SwiftUI

struct NodeFilter: View {
    @Environment(ServerListVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        Menu("Node") {
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
            
            ForEach(vm.nodes, id: \.self) {
                NodeFilterCard($vm.displayedNode, node: $0)
            }
        }
    }
}

#Preview {
    NodeFilter()
        .darkSchemePreferred()
        .environment(ServerListVM())
}
