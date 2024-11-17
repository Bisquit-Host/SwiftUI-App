import SwiftUI
import ImagePlayground
import PhotosUI

@available(iOS 18.1, macOS 15.1, *)
struct ImagePlayground: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(\.dismiss) private var dismiss
    
    private let url: URL?
    private let root: String
    
    init(_ url: URL? = nil, root: String) {
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
        var concepts: [ImagePlaygroundConcept] = []
        
        for concept in imageDescriptions {
            concepts.append(.text(concept))
        }
        
        return concepts
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
            
            //            if let url = genImageURL {
            //                AsyncImage(url: url) { image in
            //                    image
            //                        .resizable()
            //                        .aspectRatio(contentMode: .fit)
            //                        .frame(maxWidth: 300, maxHeight: 300)
            //                        .clipShape(.rect(cornerRadius: 16))
            //                } placeholder: {
            //                    ProgressView()
            //                }
            //            }
            
            if let selectedImage {
                selectedImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
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
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Image(systemName: selectedImage == nil ? "photo.badge.plus" : "photo.badge.checkmark")
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
                    vm.handleFileImport([genImageURL], root: root)
                }
                
                dismiss()
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

fileprivate struct AllowDrag: ViewModifier {
    private let url: URL?
    
    init(_ url: URL?) {
        self.url = url
    }
    
    func body(content: Content) -> some View {
        if let url {
            content
                .onDrag {
                    NSItemProvider(object: url as NSURL)
                }
        } else {
            content
        }
    }
}

fileprivate extension View {
    func allowDrag(_ url: URL?) -> some View {
        self.modifier(AllowDrag(url))
    }
}

@available(iOS 18.1, macOS 15.1, *)
#Preview {
    NavigationView {
        ImagePlayground(root: "")
    }
}
