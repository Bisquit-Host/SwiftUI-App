import SwiftUI
import PhotosUI
import AVKit

/// iOS 16+
// MARK: Image Picker with Drag & Drop
struct ImagePicker: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(\.dismiss) private var dismiss
    
    var title: String
    var subTitle: String
    var systemImage: String
    var root: String
    var tint: Color
    
    init(
        title: String,
        subtitle: String,
        icon: String = "square.and.arrow.up",
        root: String = "",
        tint: Color = .blue
    ) {
        self.title = title
        self.subTitle = subtitle
        self.systemImage = icon
        self.root = root
        self.tint = tint
    }
    
    @State private var isLoading = false
    @State private var showImagePicker = false
    
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
                    vm.handleFileImport(previewUrls, root: root)
                    dismiss()
                }
            }
            .semibold()
            .padding(20)
            .background(.ultraThinMaterial)
            
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
            .frame(width: 300, height: 250)
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
                showImagePicker = true
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
                isPresented: $showImagePicker,
                selection: $pickerItems,
                selectionBehavior: .ordered
            )
            .toolbar {
                if !previewUrls.isEmpty {
                    Button("Clear") {
                        previewUrls = []
                    }
                }
            }
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
            
            if let last = previewUrls.last {
                UploadPreviewList(last)
                    .transition(.opacity)
            }
            
            if previewUrls.count > 1 {
                Text("\(previewUrls.count - 1) more files")
                    .padding()
            }
        }
    }
    
    func writeDataToTemporaryURL(_ data: Data, pathExtension: String = "") -> URL? {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        
        let temporaryFileURL = temporaryDirectoryURL
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(pathExtension)
        
        do {
            try data.write(to: temporaryFileURL)
            return temporaryFileURL
        } catch {
            print("Error writing video data to temporary file: \(error)")
            return nil
        }
    }
    
    func extractImageOrVideo(_ photoItems: [PhotosPickerItem]) {
        Task.detached {
            for item in photoItems {
                guard let identifier = item.supportedContentTypes.first?.identifier
                    .replacingOccurrences(of: "public.", with: "")
                    .replacingOccurrences(of: "mpeg-4", with: "mp4")
                else {
                    print("Extension not determined")
                    return
                }
                
                print("Item: \(identifier)")
                
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
}

extension View {
    @ViewBuilder
    func libraryPicker(
        _ isPresented: Binding<Bool>,
        title: String,
        subtitle: String,
        icon: String = "square.and.arrow.up",
        root: String = "",
        tint: Color = .blue
    ) -> some View {
        self.sheet(isPresented) {
            NavigationView {
                ImagePicker(
                    title: title,
                    subtitle: subtitle,
                    icon: icon,
                    root: root,
                    tint: tint
                )
                .padding()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    Text("Preview")
        .environmentObject(FileTabVM(""))
        .libraryPicker(.constant(true), title: "1", subtitle: "2")
}
