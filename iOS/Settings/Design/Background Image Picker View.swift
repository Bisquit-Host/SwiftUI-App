import SwiftUI

func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

func saveImageToDisk(_ image: UIImage) -> String? {
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

func loadImageFromDisk(_ fileName: String) -> UIImage? {
    let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
    
    // Check whether the file exists
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
        print("File does not exist at path:", fileURL.path)
        return nil
    }
    
    do {
        let data = try Data(contentsOf: fileURL)
        
        if data.isEmpty {
            print("Data is empty at path:", fileURL.path)
            return nil
        }
        
        if let image = UIImage(data: data) {
            return image
        } else {
            print("Failed to create UIImage from data at path:", fileURL.path)
            return nil
        }
    } catch {
        print("Error loading data from path: \(fileURL.path) - \(error)")
        return nil
    }
}

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
                
                if let image, let fileName = saveImageToDisk(image) {
                    UserDefaults.standard.set(fileName, forKey: "background_image_fileName")
                }
                
                store.updateBackground.toggle()
            }
        }
        .onAppear {
            if let fileName = UserDefaults.standard.string(forKey: "background_image_fileName"),
               let image = loadImageFromDisk(fileName) {
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

#Preview {
    BackgroundImagePickerView()
}
