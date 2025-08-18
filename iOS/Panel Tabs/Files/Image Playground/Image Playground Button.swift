import SwiftUI

struct ImagePlaygroundButton: View {
    @Environment(\.supportsImagePlayground) private var supportsPlayground
    
    private let root: String
    
    init(_ root: String = "") {
        self.root = root
    }
    
    @State private var sheetPlayground = false
    
    var body: some View {
        if supportsPlayground {
            Button {
                sheetPlayground = true
            } label: {
                Image(systemName: "apple.intelligence")
                    .symbolRenderingMode(.multicolor)
            }
            .keyboardShortcut("P")
            .sheet($sheetPlayground) {
                NavigationStack {
                    ImagePlayground(at: root)
                }
            }
        }
    }
}

#Preview {
    ImagePlaygroundButton()
}
