import SwiftUI

func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

func saveImageToDisk(image: UIImage) -> String? {
    guard let data = image.heicData() else {
        print("Could not get HEIC data from image")
        return nil
    }
    
    let fileName = UUID().uuidString + ".heic"
    let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
    
    do {
        try data.write(to: fileURL)
        print("Image saved at: \(fileURL.path)")
        
        // Return only the file name
        return fileName
    } catch {
        print("Error saving image:", error)
        return nil
    }
}

func loadImageFromDisk(fileName: String) -> UIImage? {
    let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
    
    // Check whether the file exists
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
        print("File does not exist at path: \(fileURL.path)")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: fileURL)
        
        if data.isEmpty {
            print("Data is empty at path: \(fileURL.path)")
            return nil
        }
        
        if let image = UIImage(data: data) {
            return image
        } else {
            print("Failed to create UIImage from data at path: \(fileURL.path)")
            return nil
        }
    } catch {
        print("Error loading data from path: \(fileURL.path) - \(error)")
        return nil
    }
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
                
                if let fileName = saveImageToDisk(image: image) {
                    UserDefaults.standard.set(fileName, forKey: "background_image_fileName")
                }
            }
        }
        .onAppear {
            if let fileName = UserDefaults.standard.string(forKey: "background_image_fileName"),
               let image = loadImageFromDisk(fileName: fileName) {
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
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        Image(uiImage: selectedImage ?? .darkBackgroundInfo)
            .resizable()
            .blur(radius: 55, opaque: true)
            .ignoresSafeArea()
            .onAppear {
                if let fileName = UserDefaults.standard.string(forKey: "background_image_fileName"),
                   let image = loadImageFromDisk(fileName: fileName) {
                    selectedImage = image
                }
            }
    }
}

#Preview {
    BackgroundImagePickerView()
}
