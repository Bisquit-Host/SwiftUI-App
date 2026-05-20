import SwiftUI
import PhotosUI

struct AvatarPicker: View {
    @Environment(BillingSettingsVM.self) private var vm
    @Environment(DashboardVM.self) private var dashboardVM
    
    @Binding private var avatarPreview: UIImage?
    
    init(_ avatarPreview: Binding<UIImage?>) {
        _avatarPreview = avatarPreview
    }
    
    @State private var avatarPickerItem: PhotosPickerItem?
    @State private var showAvatarPicker = false
    @State private var isUploadingAvatar = false
    
    private let offset = 10.0
    
    var body: some View {
        Button {
            showAvatarPicker = true
        } label: {
            VStack {
                if isUploadingAvatar {
                    ProgressView()
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .fontSize(14)
                }
            }
            .frame(32)
#if !os(visionOS)
            .glassEffect(in: .circle)
#endif
        }
        .photosPicker(isPresented: $showAvatarPicker, selection: $avatarPickerItem, matching: .images, photoLibrary: .shared())
        .animation(.default, value: isUploadingAvatar)
        .disabled(isUploadingAvatar)
        .foregroundStyle(.foreground)
        .offset(x: offset, y: -offset)
        .onChange(of: avatarPickerItem) { _, newValue in
            if let newValue {
                handleAvatarChange(newValue)
            }
        }
    }
    
    private func handleAvatarChange(_ item: PhotosPickerItem) {
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                SystemAlert.error("Could not read image")
                return
            }
            
            let maxBytes = 5 * 1024 * 1024
            
            if data.count > maxBytes {
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useMB]
                formatter.countStyle = .file
                
                let sizeString = formatter.string(fromByteCount: Int64(data.count))
                let limitString = formatter.string(fromByteCount: Int64(maxBytes))
                
                SystemAlert.error("Avatar too large", subtitle: "Max \(limitString). Selected file is \(sizeString)")
                avatarPickerItem = nil
                return
            }
            
            let ext = item.supportedContentTypes.first?.preferredFilenameExtension ?? "jpg"
            let mime = item.supportedContentTypes.first?.preferredMIMEType
            let filename = "avatar.\(ext)"
            
            avatarPreview = UIImage(data: data)
            isUploadingAvatar = true
            
            let uploaded = await vm.updateAvatar(with: data, filename: filename, mimeType: mime)
            
            isUploadingAvatar = false
            avatarPickerItem = nil
            
            if uploaded != nil {
                await dashboardVM.fetchUserInfo()
                avatarPreview = nil
            }
        }
    }
}
