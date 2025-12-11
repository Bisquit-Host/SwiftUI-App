import SwiftUI
import PhotosUI

struct BillingAvatarHeader: View {
    @Environment(BillingSettingsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    @State private var showAvatarPicker = false
    @State private var avatarPickerItem: PhotosPickerItem?
    @State private var avatarPreview: UIImage?
    @State private var isUploadingAvatar = false
    
    var body: some View {
        let uploading = isUploadingAvatar
        
        HStack(spacing: 20) {
            avatarImage(for: user)
                .overlay(alignment: .topTrailing) {
                    Button {
                        showAvatarPicker = true
                    } label: {
                        VStack {
                            if uploading {
                                ProgressView()
                            } else {
                                Image(systemName: "photo.on.rectangle.angled")
                            }
                        }
                        .frame(40)
                        .glassEffect(in: .circle)
                    }
                    .photosPicker(isPresented: $showAvatarPicker, selection: $avatarPickerItem, matching: .images, photoLibrary: .shared())
                    .animation(.default, value: uploading)
                    .disabled(isUploadingAvatar)
                    .foregroundStyle(.foreground)
                    .offset(x: 12, y: -12)
                }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(user.name)
                    .subheadline(.semibold)
                    .lineLimit(2)
                
                Text("Visible in tickets and chats")
                    .footnote()
                    .secondary()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
        .onChange(of: avatarPickerItem) { _, newValue in
            if let newValue {
                handleAvatarChange(newValue)
            }
        }
    }
    
    @ViewBuilder
    private func avatarImage(for user: BillingUser) -> some View {
        let size: CGFloat = 72
        
        ZStack {
            if let avatarPreview {
                Image(uiImage: avatarPreview)
                    .resizable()
                    .scaledToFill()
                
            } else if let avatar = user.avatar, let url = URL(string: avatar) {
                AsyncImage(url: url) {
                    switch $0 {
                    case .empty:
                        ProgressView()
                        
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                        
                    case .failure:
                        placeholderInitial(for: user)
                        
                    @unknown default:
                        placeholderInitial(for: user)
                    }
                }
            } else {
                placeholderInitial(for: user)
            }
        }
        .animation(.default, value: avatarPreview)
        .frame(size)
        .clipShape(.circle)
        .overlay {
            Circle()
                .stroke(.primary.opacity(0.08), lineWidth: 1)
        }
    }
    
    @ViewBuilder
    private func placeholderInitial(for user: BillingUser) -> some View {
        let initial = user.name.first.map { String($0) } ?? "?"
        
        Circle()
            .fill(.blue.opacity(0.12))
            .overlay {
                Text(initial.uppercased())
                    .title3(.semibold)
                    .foregroundStyle(.blue)
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
