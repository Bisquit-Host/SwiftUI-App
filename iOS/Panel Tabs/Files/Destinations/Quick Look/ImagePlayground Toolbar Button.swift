import ScrechKit

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
        if supportsPlayground {
            SFButton("apple.intelligence") {
                sheetPlayground = true
            }
            .sheet($sheetPlayground) {
                NavigationStack {
                    ImagePlayground(url, at: root)
                }
            }
        }
    }
}

//#Preview {
//    ImagePlaygroundToolbarButton()
//        .darkSchemePreferred()
//}
