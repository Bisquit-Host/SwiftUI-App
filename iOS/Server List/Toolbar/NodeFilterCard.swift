import SwiftUI

struct NodeFilterCard: View {
    @Binding private var displayedNode: String
    private let node: String
    
    init(_ displayedNode: Binding<String>, node: String) {
        _displayedNode = displayedNode
        self.node = node
    }
    
    var body: some View {
        Button {
            withAnimation {
                displayedNode = node
            }
        } label: {
            let nodeName = node.capitalized
            
            if displayedNode == node {
                Label(nodeName, systemImage: "checkmark")
            } else {
                Text(nodeName)
            }
        }
    }
}

#Preview {
    NodeFilterCard(.constant(""), node: "test")
}
