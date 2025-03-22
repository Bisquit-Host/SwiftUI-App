import SwiftUI

struct BackgroundImage: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        Image(uiImage: selectedImage ?? .darkBackgroundInfo)
            .resizable()
            .blur(radius: 55, opaque: true)
            .ignoresSafeArea()
            .onAppear {
                update()
            }
            .onChange(of: store.updateBackground) {
                update()
            }
    }
    
    private func update() {
        if let fileName = UserDefaults.standard.string(forKey: "background_image_fileName"),
           let image = loadImageFromDisk(fileName) {
            selectedImage = image
        }
    }
}
