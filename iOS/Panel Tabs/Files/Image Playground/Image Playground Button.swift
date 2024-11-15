import SwiftUI

@available(iOS 18.1, macOS 15.1, *)
struct ImagePlaygroundButton: View {
    @Environment(\.supportsImagePlayground) private var supportsImagePlayground
    
    @State private var sheetImagePlayground = false
    
    var body: some View {
        Button("Image Playground") {
            sheetImagePlayground = true
        }
        .disabled(!supportsImagePlayground)
        .sheet($sheetImagePlayground) {
            ImagePlayground()
        }
    }
}

@available(iOS 18.1, macOS 15.1, *)
#Preview {
    ImagePlaygroundButton()
}
