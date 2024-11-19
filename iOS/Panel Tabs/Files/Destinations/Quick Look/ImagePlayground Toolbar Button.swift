import SwiftUI

@available(iOS 18.1, *)
struct ImagePlaygroundToolbarButton: View {
    @Environment(\.supportsImagePlayground) private var supportsImagePlayground
    
    private let url: URL, root, name: String
    
    init(_ url: URL, root: String, name: String) {
        self.url = url
        self.root = root
        self.name = name
    }
    
    @State private var sheetPlayground = false
    
    var body: some View {
        Button {
            sheetPlayground = true
        } label: {
            Image(.appleIntelligence)
                .resizable()
                .frame(width: 25, height: 25)
                .opacity(supportsImagePlayground ? 1 : 0.3)
        }
        .disabled(!supportsImagePlayground)
        .sheet($sheetPlayground) {
            NavigationView {
                ImagePlayground(url, root: root)
            }
        }
    }
}

//@available(iOS 18.1, *)
//#Preview {
//    ImagePlaygroundToolbarButton()
//}
