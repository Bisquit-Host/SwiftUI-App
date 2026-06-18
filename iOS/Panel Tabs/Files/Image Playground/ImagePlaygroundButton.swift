import ScrechKit

struct ImagePlaygroundButton: View {
    @Environment(\.supportsImagePlayground) private var supportsPlayground
    
    private let root: String
    
    init(_ root: String = "") {
        self.root = root
    }
    
    @State private var sheetPlayground = false
    
    var body: some View {
        if supportsPlayground {
            SFButton("apple.intelligence") {
                sheetPlayground = true
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
        .darkSchemePreferred()
}
