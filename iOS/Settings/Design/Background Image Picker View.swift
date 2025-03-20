import SwiftUI

// Helper functions to save and load images from disk.
func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

func saveImageToDisk(image: UIImage) -> String? {
    guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
    let filename = UUID().uuidString + ".jpg"
    let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
    
    do {
        try data.write(to: fileURL)
        return fileURL.path
    } catch {
        print("Error saving image:", error)
        return nil
    }
}

func loadImageFromDisk(filePath: String) -> UIImage? {
    let url = URL(fileURLWithPath: filePath)
    
    guard let data = try? Data(contentsOf: url) else {
        return nil
    }
    
    return UIImage(data: data)
}

struct BackgroundImagePickerView: View {
    @AppStorage("background_image_path") private var backgroundImagePath: String?
    
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
                
                // Save the image on disk and store the file path.
                if let path = saveImageToDisk(image: image) {
                    backgroundImagePath = path
                }
            }
        }
        .onAppear {
            // Attempt to load the image from the saved file path.
            if let path = backgroundImagePath, let image = loadImageFromDisk(filePath: path) {
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

struct BackgroundImage: View {
    @AppStorage("background_image_path") private var backgroundImagePath: String?
    
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        Image(uiImage: selectedImage ?? .darkBackgroundInfo)
            .resizable()
            .blur(radius: 55, opaque: true)
            .ignoresSafeArea()
            .onAppear {
                if let path = backgroundImagePath, let image = loadImageFromDisk(filePath: path) {
                    selectedImage = image
                }
            }
    }
}

#Preview {
    BackgroundImagePickerView()
}
