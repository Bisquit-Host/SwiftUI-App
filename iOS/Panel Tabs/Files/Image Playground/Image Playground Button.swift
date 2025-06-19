import SwiftUI

@available(iOS 18.1, *)
struct ImagePlaygroundButton: View {
    @Environment(\.supportsImagePlayground) private var supportsPlayground
    
    private let root: String
    
    init(_ root: String = "") {
        self.root = root
    }
    
    @State private var sheetPlayground = false
    
    var body: some View {
        Button {
            sheetPlayground = true
        } label: {
            let icon = supportsPlayground ? "apple.intelligence" : "apple.intelligence.badge.xmark"
            Image(systemName: icon)
        }
        .keyboardShortcut("P")
        .disabled(!supportsPlayground)
        .sheet($sheetPlayground) {
            NavigationView {
                ImagePlayground(at: root)
            }
        }
    }
}

@available(iOS 18.1, *)
#Preview {
    ImagePlaygroundButton()
}
