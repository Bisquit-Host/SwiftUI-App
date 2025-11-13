import SwiftUI
import ImagePlayground
import PhotosUI

struct ImagePlayground: View {
    @EnvironmentObject private var vm: FileTabVM
    
    @Environment(\.dismiss) private var dismiss
    
    private let url: URL?
    private let root: String
    
    init(_ url: URL? = nil, at root: String) {
        self.url = url
        self.root = root
    }
    
    @State private var showImagePlayground = false
    @State private var genImageURL: URL?
    @State private var selectedImage: Image?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var imageDescription = ""
    @State private var imageDescriptions: [String] = []
    
    private var imageConcepts: [ImagePlaygroundConcept] {
        imageDescriptions.compactMap {
            ImagePlaygroundConcept.text($0)
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            ForEach(imageDescriptions, id: \.self) { concept in
                Button(concept) {
                    imageDescriptions.removeAll {
                        $0 == concept
                    }
                }
                .semibold()
                .padding(10)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                .padding(5)
            }
            
            if let selectedImage {
                selectedImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(300)
                    .clipShape(.rect(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    }
                    .contentShape(.rect(cornerRadius: 16))
                    .allowDrag(genImageURL)
            }
            
            TextField("Describe an image", text: $imageDescription)
                .title3()
                .padding()
                .multilineTextAlignment(.center)
                .onSubmit {
                    if !imageDescription.isEmpty {
                        imageDescriptions.append(imageDescription)
                        imageDescription = ""
                    }
                }
            
            Spacer()
            
            HStack {
                if let genImageURL {
                    ShareLink(item: genImageURL) {
                        Image(systemName: "square.and.arrow.up")
                            .title3(.semibold)
                            .padding(.horizontal)
                            .frame(height: 64)
                            .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                            .padding(5)
                    }
                }
                
                Button("Generate") {
                    showImagePlayground = true
                }
                .title3(.semibold)
                .padding(.horizontal)
                .frame(height: 64)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                .padding(5)
                
                let hasSelectedImage = selectedImage != nil
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Image(systemName: hasSelectedImage ? "photo.badge.plus" : "photo.badge.checkmark")
                        .symbolRenderingMode(.multicolor)
                        .title2(.semibold)
                        .padding(.horizontal)
                        .frame(height: 64)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                        .padding(5)
                }
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task {
#if os(macOS)
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = NSImage(data: data) {
                            selectedImage = Image(nsImage: uiImage)
                        }
#else
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = Image(uiImage: uiImage)
                        }
#endif
                    }
                }
            }
        }
        .padding()
        .task {
            if let url {
                changeSelectedImage(url)
            }
        }
        .toolbar {
            Button("Upload") {
                if let genImageURL {
                    Task {
                        await vm.handleFileImport([genImageURL], at: root) {
                            dismiss()
                        }
                    }
                }
            }
            .disabled(genImageURL == nil)
        }
        .imagePlaygroundSheet(
            isPresented: $showImagePlayground,
            concepts: imageConcepts,
            sourceImage: selectedImage
        ) { url in
            genImageURL = url
            
            selectedPhotoItem = nil
            
            changeSelectedImage(url)
        }
    }
    
    private func changeSelectedImage(_ url: URL) {
#if os(macOS)
        if let data = try? Data(contentsOf: url),
           let uiImage = NSImage(data: data) {
            selectedImage = Image(nsImage: uiImage)
        }
#else
        if let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            selectedImage = Image(uiImage: uiImage)
        }
#endif
    }
}

#Preview {
    NavigationStack {
        ImagePlayground(at: "")
    }
    .darkSchemePreferred()
}
