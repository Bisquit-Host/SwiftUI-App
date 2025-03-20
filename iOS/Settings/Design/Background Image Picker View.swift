import SwiftUI

struct BackgroundImagePickerView: View {
    @AppStorage("backgroundImage") private var backgroundImageData: Data?
    
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
                
                // Convert UIImage to PNG Data and store it
                if let data = image.pngData() {
                    backgroundImageData = data
                }
            }
        }
        .onAppear {
            // Load any saved image from AppStorage on view appearance
            if let data = backgroundImageData, let image = UIImage(data: data) {
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
