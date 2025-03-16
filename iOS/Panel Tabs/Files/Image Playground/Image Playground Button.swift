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
//                if supportsImagePlayground {
                    Image(.appleIntelligence)
                        .resizable()
                        .frame(width: 35, height: 35)
                        .clipShape(.circle)
                        .blur(radius: 3)
//                }
                
                Image(.appleIntelligence)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(.circle)
//                    .opacity(supportsImagePlayground ? 1 : 0.2)
            }
            //            HStack {
            //                Text("Image Playground")
            //                    .semibold()
            //                    .rounded()
            //
            //                Spacer()
            //
            //                ZStack {
            //                    if supportsImagePlayground {
            //                        Image(.appleIntelligence)
            //                            .resizable()
            //                            .frame(width: 28, height: 28)
            //                            .blur(radius: 3)
            //                    }
            //
            //                    Image(.appleIntelligence)
            //                        .resizable()
            //                        .frame(width: 25, height: 25)
            //                        .frame(width: 25, height: 25)
            //                        .opacity(supportsImagePlayground ? 1 : 0.3)
            //                }
            //            }
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
    ImagePlaygroundButton()
}
