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
            HStack {
                Text("Image Playground")
                    .semibold()
                    .rounded()
                
                Spacer()
                
                ZStack {
                    if supportsImagePlayground {
                        Image(.appleIntelligence)
                            .resizable()
                            .frame(width: 28, height: 28)
                            .blur(radius: 3)
                    }
                    
                    Image(.appleIntelligence)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .frame(width: 25, height: 25)
                        .opacity(supportsImagePlayground ? 1 : 0.3)
                }
            }
        }
        .keyboardShortcut("P")
        .foregroundStyle(.foreground)
        .disabled(!supportsImagePlayground)
        .sheet($sheetImagePlayground) {
            NavigationView {
                ImagePlayground(root: root)
            }
        }
    }
}

@available(iOS 18.1, *)
#Preview {
    List {
        ImagePlaygroundButton()
    }
}
