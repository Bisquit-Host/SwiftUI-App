import SwiftUI
import PhotosUI
import AVKit

/// iOS 16+
// MARK: Image Picker with Drag & Drop
struct ImagePicker: View {
    @EnvironmentObject private var vm: FileTabVM
    
    @Environment(\.dismiss) private var dismiss
    
    var root: String
    var tint: Color
    
    init(
        at root: String = "",
        tint: Color = .blue
    ) {
        self.root = root
        self.tint = tint
    }
    
    @State private var isLoading = false
    @State private var showLibraryPicker = false
    
    @State private var previewUrls: [URL] = []
    @State private var pickerItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel", role: .destructive) {
                    vm.sheetPreview = false
                }
                
                Spacer()
                
                Button("Upload") {
                    Task {
                        await vm.handleFileImport(previewUrls, at: root) {
                            dismiss()
                        }
                    }
                }
            }
            .semibold()
            .padding(20)
            .background(.ultraThinMaterial)
            .overlay {
                if isLoading {
                    ProgressView()
                        .padding(10)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 5))
                }
            }
            .animation(.spring, value: isLoading)
            .contentShape(.rect)
            .onTapGesture {
                showLibraryPicker = true
            }
            .onChange(of: pickerItems) { _, newItems in
                extractImageOrVideo(newItems)
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
            .photosPicker(
                isPresented: $showLibraryPicker,
                selection: $pickerItems,
                selectionBehavior: .ordered
            )
            .dropDestination(for: Data.self) { items, location in
                for item in items {
                    if let url = writeDataToTemporaryURL(item) {
                        withAnimation {
                            previewUrls.append(url)
                        }
                    }
                }
                
                return false
            }
            
            UploadPreviewList(previewUrls)
                .transition(.opacity)
        }
    }
    
    private func extractImageOrVideo(_ photoItems: [PhotosPickerItem]) {
        Task.detached {
            for item in photoItems {
                guard let identifier = item.supportedContentTypes.first?.identifier
                    .replacingOccurrences(of: "public.", with: "")
                    .replacingOccurrences(of: "mpeg-4", with: "mp4")
                else {
                    print("Extension not determined")
                    return
                }
                
                print("Item:", identifier)
                
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        if let url = writeDataToTemporaryURL(data, pathExtension: identifier) {
                            withAnimation {
                                previewUrls.append(url)
                            }
                        }
                    }
                }
            }
        }
        
        pickerItems = []
    }
    
    private func writeDataToTemporaryURL(
        _ data: Data,
        pathExtension: String = ""
    ) -> URL? {
        let temporaryDirectoryUrl = FileManager.default.temporaryDirectory
        
        let temporaryFileUrl = temporaryDirectoryUrl
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(pathExtension)
        
        do {
            try data.write(to: temporaryFileUrl)
            return temporaryFileUrl
        } catch {
            print("Error writing video data to temporary file:", error)
            return nil
        }
    }
}
