import ScrechKit

import SwiftUI
import PhotosUI

@available(iOS 14, *)
public extension View {
    func mediaPicker(_ isPresented: Binding<Bool>, selectedURL: Binding<URL?>) -> some View {
        self.sheet(isPresented: isPresented) {
            MediaPicker(selectedURL: selectedURL)
                .ignoresSafeArea()
        }
    }
}

@available(iOS 14, *)
public struct MediaPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?

    public init(selectedURL: Binding<URL?>) {
        _selectedURL = selectedURL
    }

    public func makeUIViewController(context: Context) -> PHPickerViewController {
        let config = PHPickerConfiguration()  // No filter, allowing any file type
        let picker = PHPickerViewController(configuration: config)
        
        picker.delegate = context.coordinator
        
        return picker
    }

    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: MediaPicker

        init(_ parent: MediaPicker) {
            self.parent = parent
        }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }
            
            // Handling any file type, assuming they can be represented as a URL
            if provider.hasItemConformingToTypeIdentifier("public.item") {
                provider.loadFileRepresentation(forTypeIdentifier: "public.item") { url, error in
                    DispatchQueue.main.async {
                        if let url = url {
                            // Copy the file to a local directory if necessary or use directly
                            self.parent.selectedURL = self.persistFileToLocalDirectory(originalURL: url)
                        }
                    }
                }
            }
        }

        private func persistFileToLocalDirectory(originalURL: URL) -> URL? {
            let fileManager = FileManager.default
            let localURL = fileManager.temporaryDirectory.appendingPathComponent(originalURL.lastPathComponent)

            do {
                if fileManager.fileExists(atPath: localURL.path) {
                    try fileManager.removeItem(at: localURL)
                }
                try fileManager.copyItem(at: originalURL, to: localURL)
                return localURL
            } catch {
                print("Failed to copy file to local directory: \(error)")
                return nil
            }
        }
    }
}

struct UploadMenu: View {
    @EnvironmentObject private var vm: FileTabVM
    
    @Binding private var url: URL?
    @Binding private var image: UIImage?
    private let root: String
    
    init(
        _ image: Binding<UIImage?>,
        url: Binding<URL?>,
        root: String
    ) {
//    init(_ image: Binding<UIImage?>, root: String) {
        _image = image
        _url = url
        self.root = root
    }
    
    @State private var showFilePicker = false
    @State private var showCameraPicker = false
    @State private var showImagePicker = false
    @State private var urls: [URL] = []
    
    var body: some View {
        Menu {
            MenuButton("Choose File", icon: "folder") {
                showFilePicker = true
            }
            
            MenuButton("Take Photo", icon: "camera") {
                showCameraPicker = true
            }
            
            MenuButton("Photo Library", icon: "photo.on.rectangle") {
                showImagePicker = true
            }
        } label: {
            HStack {
                Text("Upload file")
                
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
                    .title3(.semibold)
            }
            .foregroundStyle(.foreground)
        }
        .sheet($vm.sheetPreview) {
            UploadPreview(urls, root: root)
        }
        .mediaPicker($showImagePicker, selectedURL: $url)
//        .imagePicker($showImagePicker, image: $image)
        .cameraPicker($showCameraPicker, image: $image)
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
            switch result {
            case .success(let model):
                urls = model
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            vm.sheetPreview = true
        }
    }
}
