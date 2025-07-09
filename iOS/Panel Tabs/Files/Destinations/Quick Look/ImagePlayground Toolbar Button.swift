import SwiftUI

struct ImagePlaygroundToolbarButton: View {
    @Environment(\.supportsImagePlayground) private var supportsPlayground
    
    private let url: URL
    private let root, name: String
    
    init(
        _ url: URL,
        _ root: String,
        _ name: String
    ) {
        self.url = url
        self.root = root
        self.name = name
    }
    
    @State private var sheetPlayground = false
    
    var body: some View {
        Button {
            sheetPlayground = true
        } label: {
            let icon = supportsPlayground ? "apple.intelligence" : "apple.intelligence.badge.xmark"
            Image(systemName: icon)
        }
        .disabled(!supportsPlayground)
        .sheet($sheetPlayground) {
            NavigationView {
                ImagePlayground(url, at: root)
            }
        }
    }
}

//#Preview {
//    ImagePlaygroundToolbarButton()
//}
