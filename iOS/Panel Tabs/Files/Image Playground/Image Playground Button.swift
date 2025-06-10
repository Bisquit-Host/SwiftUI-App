import SwiftUI

@available(iOS 18.1, *)
struct ImagePlaygroundButton: View {
    @Environment(\.supportsImagePlayground) private var supportsImagePlayground
    
    private let root: String
    
    init(_ root: String = "") {
        self.root = root
    }
    
    @State private var sheetImagePlayground = false
    
    var body: some View {
        Button {
            sheetImagePlayground = true
        } label: {
            ZStack {
                if supportsImagePlayground {
                    Image(.appleIntelligence)
                        .resizable()
                        .frame(35)
                        .clipShape(.circle)
                        .blur(radius: 3)
                }
                
                Image(.appleIntelligence)
                    .resizable()
                    .frame(32)
                    .clipShape(.circle)
                    .opacity(supportsImagePlayground ? 1 : 0.2)
            }
        }
        .keyboardShortcut("P")
        .disabled(!supportsImagePlayground)
        .sheet($sheetImagePlayground) {
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
