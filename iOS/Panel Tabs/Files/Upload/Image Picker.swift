import SwiftUI
import PhotosUI
import AVKit

/// iOS 16+
// MARK: Image Picker with Drag & Drop
struct ImagePicker: View {
    var title, subTitle, systemImage: String
    var tint: Color
    var onImageChange: (UIImage) -> ()
    var onVideoChange: (URL) -> ()
    
    init(
        title: String,
        subTitle: String,
        systemImage: String = "square.and.arrow.up",
        tint: Color = .blue,
        onImageChange: @escaping (UIImage) -> Void = { _ in },
        onVideoChange: @escaping (URL) -> Void = { _ in }
    ) {
        self.title = title
        self.subTitle = subTitle
        self.systemImage = systemImage
        self.tint = tint
        self.onImageChange = onImageChange
        self.onVideoChange = onVideoChange
    }
    
    @State private var showImagePicker = false
    @State private var isLoading = false
    
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var previewImage: UIImage?
    @State private var previewVideoUrl: URL? // Store the video URL for preview
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.largeTitle)
                    .imageScale(.large)
                    .foregroundStyle(tint)
                
                Text(title)
                    .font(.callout)
                    .padding(.top, 15)
                
                Text(subTitle)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .opacity(previewImage == nil ? 1 : 0)
            .frame(width: size.width, height: size.height)
            .photosPicker(isPresented: $showImagePicker, selection: $pickerItems, selectionBehavior: .ordered)
            .toolbar {
                Button("Clear") {
                    previewImage = nil
                    previewVideoUrl = nil
                }
            }
            .overlay {
                if let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(15)
                } else if let previewVideoUrl {
                    VideoPlayer(player: AVPlayer(url: previewVideoUrl))
                        .frame(width: size.width, height: size.height)
                        .cornerRadius(10)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .padding(10)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 5))
                }
            }
            .animation(.spring(), value: isLoading)
            .animation(.spring(), value: previewImage)
            .contentShape(.rect)
            .dropDestination(for: Data.self) { items, location in
#warning("Supports only one item")
                if let firstItem = items.first {
                    if let droppedImage = UIImage(data: firstItem) {
                        previewVideoUrl = nil
                        generateImageThumbnail(droppedImage, size)
                        onImageChange(droppedImage)
                        return true
                    } else {
                        let videoURL = writeDataToTemporaryURL(firstItem)
                        previewVideoUrl = videoURL
                        previewImage = nil
                        onVideoChange(videoURL)
                    }
                }
                
                return false
            }
            .onTapGesture {
                showImagePicker = true
            }
            .onChange(of: pickerItems) { _, newItems in
                extractImageOrVideo(newItems, size)
            }
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(tint.opacity(0.08).gradient)
                    
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(tint, style: .init(lineWidth: 1, dash: [12]))
                        .padding(1)
                }
            }
        }
    }
    
    func writeDataToTemporaryURL(_ data: Data) -> URL {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
        
        do {
            try data.write(to: temporaryFileURL)
            return temporaryFileURL
        } catch {
            print("Error writing video data to temporary file: \(error)")
            return temporaryDirectoryURL
        }
    }
    
    func extractImageOrVideo(_ photoItems: [PhotosPickerItem], _ viewSize: CGSize) {
        Task.detached {
            for item in photoItems {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        if let selectedImage = UIImage(data: data) {
                            previewVideoUrl = nil
                            generateImageThumbnail(selectedImage, viewSize)
                            onImageChange(selectedImage)
                        } else {
                            let videoURL = writeDataToTemporaryURL(data)
                            previewVideoUrl = videoURL
                            previewImage = nil
                            onVideoChange(videoURL)
                        }
                    }
                }
            }
            
            self.pickerItems = []
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
    @ViewBuilder
    func libraryPicker(
        _ isPresented: Binding<Bool>,
        title: String,
        subTitle: String,
        systemImage: String = "square.and.arrow.up",
        tint: Color = .blue,
        onImageChange: @escaping (UIImage) -> Void = { _ in },
        onVideoChange: @escaping (URL) -> Void = { _ in }
    ) -> some View {
        self.sheet(isPresented) {
            NavigationView {
                ImagePicker(
                    title: title,
                    subTitle: subTitle,
                    systemImage: systemImage,
                    tint: tint,
                    onImageChange: onImageChange,
                    onVideoChange: onVideoChange
                )
                .padding()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    Text("Preview")
        .libraryPicker(.constant(true), title: "1", subTitle: "2")
}
