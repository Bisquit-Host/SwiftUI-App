import SwiftUI
import ImagePlayground
import PhotosUI

@available(iOS 18.1, macOS 15.1, *)
struct ImagePlayground: View {
    @State private var showImagePlayground = false
    
    @State private var genImageURL: URL?
    
    @State private var selectedImage: Image?
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        VStack {
            if let url = genImageURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300, maxHeight: 300)
                } placeholder: {
                    ProgressView()
                }
            }
            
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Text("Pick Image")
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = Image(uiImage: uiImage)
                    }
                }
            }
            
            if let selectedImage {
                selectedImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
            }
            
            Button("Show Generation Sheet") {
                showImagePlayground = true
            }
            .imagePlaygroundSheet(
                isPresented: $showImagePlayground,
                concepts: [ImagePlaygroundConcept.text("Sunset over mountains")],
                sourceImage: selectedImage
            ) { url in
                genImageURL = url
            }
        }
        .padding()
    }
}

@available(iOS 18.1, macOS 15.1, *)
#Preview {
    ImagePlayground()
}
