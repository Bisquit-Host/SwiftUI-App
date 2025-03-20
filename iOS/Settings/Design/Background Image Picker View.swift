import SwiftUI

func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

func saveImageToDisk(image: UIImage) -> String? {
    guard let data = image.jpegData(compressionQuality: 1) else { return nil }
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
    
    guard
        FileManager.default.fileExists(atPath: url.path),
        let data = try? Data(contentsOf: url)
    else {
        return nil
    }
    
    return UIImage(data: data)
}

struct BackgroundImagePickerView: View {
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
                
                if let path = saveImageToDisk(image: image) {
                    UserDefaults.standard.set(path, forKey: "background_image_path")
                }
            }
        }
        .onAppear {
            if let path = UserDefaults.standard
                .string(forKey: "background_image_path"),
               let image = loadImageFromDisk(filePath: path) {
                selectedImage = image
            }
        }
        .navigationTitle("Image Picker")
        .background {
            if let selectedImage = selectedImage {
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
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        Image(uiImage: selectedImage ?? .darkBackgroundInfo)
            .resizable()
            .blur(radius: 55, opaque: true)
            .ignoresSafeArea()
            .onAppear {
                if let path = UserDefaults.standard
                    .string(forKey: "background_image_path"),
                   let image = loadImageFromDisk(filePath: path) {
                    selectedImage = image
                }
            }
    }
}

#Preview {
    BackgroundImagePickerView()
}
