import SwiftUI

struct BackgroundImagePickerView: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        VStack {
            BackgroundImagePicker(
                title: "Drag & Drop",
                subTitle: "Tap to add an Image",
                systemImage: "square.and.arrow.up",
                tint: .blue
            ) { image in
                selectedImage = image
                
                if let image, let fileName = BackgroundImageHelper.saveImageToDisk(image) {
                    UserDefaults.standard.set(fileName, forKey: "background_image_fileName")
                }
                
                store.updateBackground.toggle()
            }
        }
        .onAppear {
            if let fileName = UserDefaults.standard.string(forKey: "background_image_fileName"),
               let image = BackgroundImageHelper.loadImageFromDisk(fileName) {
                selectedImage = image
            }
        }
        .navigationTitle("Image Picker")
        .background {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .blur(radius: 55, opaque: true)
                    .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    BackgroundImagePickerView()
}
