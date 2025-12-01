import SwiftUI
import PhotosUI

/// iOS 16+
// MARK: Custom Image Picker with Drag & Drop
struct BackgroundImagePicker: View {
    var title, subTitle: LocalizedStringKey
    var systemImage: String
    var tint: Color
    var onImageChange: (UIImage?) -> ()
    
    @State private var showImagePicker = false
    @State private var photoItem: PhotosPickerItem?
    @State private var previewImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack(spacing: 10) {
                Image(systemName: systemImage)
                    .largeTitle()
                    .imageScale(.large)
                    .foregroundStyle(tint)
                
                Text(title)
                    .callout()
                
                Text(subTitle)
                    .caption()
                    .foregroundStyle(.gray)
                
                Button("Clear") {
                    previewImage = nil
                    onImageChange(previewImage)
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .foregroundStyle(.foreground)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.ultraThinMaterial, lineWidth: 1)
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.ultraThinMaterial, lineWidth: 1)
            }
            .frame(width: size.width, height: size.height)
            .overlay {
                // Loading UI
                
                if isLoading {
                    ProgressView()
                        .padding(10)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 5))
                }
            }
            .animation(.snappy, value: isLoading)
            .animation(.snappy, value: previewImage)
            .contentShape(.rect)
            // Drop Action and Retreving Dropped Image
            .dropDestination(for: Data.self) { items, _ in
                if let firstItem = items.first, let droppedImage = UIImage(data: firstItem) {
                    // Sending the Image using the callback
                    generateImageThumbnail(droppedImage, size)
                    onImageChange(droppedImage)
                    
                    return true
                }
                
                return false
            } isTargeted: { _ in
                
            }
            .onTapGesture {
                showImagePicker.toggle()
            }
            .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
            .optionalViewModifier { contentView in
                contentView
                    .onChange(of: photoItem) { _, newValue in
                        if let newValue {
                            // Process Selected Image
                            extractImage(newValue, size)
                        }
                    }
            }
            .background {
                ZStack {
                    ConcentricRectangle(corners: .concentric, isUniform: true)
                        .fill(tint.opacity(0.08).gradient)
                    
                    ConcentricRectangle(corners: .concentric, isUniform: true)
                        .stroke(tint, style: .init(lineWidth: 1, dash: [12]))
                        .padding(1)
                }
                .padding(16)
            }
        }
    }
    
    private func extractImage(_ photoItem: PhotosPickerItem, _ viewSize: CGSize) {
        Task.detached {
            guard let imageData = try? await photoItem.loadTransferable(type: Data.self) else {
                return
            }
            
            /// UI Must be Updated on Main Thread
            await MainActor.run {
                if let selectedImage = UIImage(data: imageData) {
                    /// Creating Preview
                    generateImageThumbnail(selectedImage, viewSize)
                    
                    /// Send Orignal Image to Callback
                    onImageChange(selectedImage)
                }
                
                self.photoItem = nil
            }
        }
    }
    
    func generateImageThumbnail(_ image: UIImage, _ size: CGSize) {
        isLoading = true
        
        Task.detached {
            let thumbnailImage = await image.byPreparingThumbnail(ofSize: size)
            
            await MainActor.run {
                previewImage = thumbnailImage
                isLoading = false
            }
        }
    }
}

extension View {
    func optionalViewModifier<Content: View> (content: @escaping (Self) -> Content) -> some View {
        content(self)
    }
}

#Preview {
    BackgroundImagePickerView()
        .darkSchemePreferred()
}
