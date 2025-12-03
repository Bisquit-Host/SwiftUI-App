import SwiftUI
import PhotosUI

struct BillingAccountSection: View {
    @Environment(BillingSettingsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    @State private var alertRename = false
    @State private var alertEmail = false
    @State private var alertLogin = false
    @State private var avatarPickerItem: PhotosPickerItem?
    @State private var avatarPreview: UIImage?
    @State private var isUploadingAvatar = false
    
    var body: some View {
        @Bindable var vm = vm
        
        BillingSectionCard("Account") {
            avatarHeader(user)
            
            Divider()
            
            BillingAccountRow("Email", icon: "envelope.fill", tint: .blue, value: user.email) {
                vm.newEmail = user.email
                alertEmail = true
            }
            
            BillingAccountRow("Name", icon: "person.fill", tint: .cyan, value: user.name) {
                vm.newName = user.name
                alertRename = true
            }
            
            BillingAccountRow("Login", icon: "at", tint: .indigo, value: user.login) {
                vm.newLogin = user.login
                alertLogin = true
            }
            
            BillingAccountRow("Language", icon: "character.cursor.ibeam", tint: .mint, value: user.lang.uppercased())
            BillingAccountRow("Currency", icon: "dollarsign", tint: .yellow, value: user.currency)
        }
        .alert("Change email", isPresented: $alertEmail) {
            TextField("New email", text: $vm.newEmail)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .limitInputLength($vm.newEmail, length: 100)
            
            Button("Change", role: .destructive) {
                changeEmail()
            }
        } message: {
            Text("You will receive a confirmation email to complete the change")
        }
        .alert("Change login", isPresented: $alertLogin) {
            TextField("New login", text: $vm.newLogin)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .limitInputLength($vm.newLogin, length: 100)
            
            Button("Change", role: .destructive) {
                changeLogin()
            }
        }
        .alert("Change name", isPresented: $alertRename) {
            TextField("New name", text: $vm.newName)
                .autocorrectionDisabled()
                .limitInputLength($vm.newName, length: 100)
            
            Button("Change", role: .destructive) {
                if vm.newName != user.name {
                    change()
                }
            }
        }
        .onChange(of: avatarPickerItem) { _, newValue in
            if let newValue {
                handleAvatarChange(newValue)
            }
        }
    }
    
    private func change() {
        Task {
            await vm.changeName {
                await dashboardVM.fetchUserInfo()
            }
        }
    }
    
    private func changeEmail() {
        Task {
            await vm.changeEmail()
        }
    }
    
    private func changeLogin() {
        Task {
            await vm.changeLogin {
                await dashboardVM.fetchUserInfo()
            }
        }
    }
    
    @ViewBuilder
    private func avatarHeader(_ user: BillingUser) -> some View {
        HStack(spacing: 14) {
            avatarImage(for: user)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(user.name)
                    .subheadline(.semibold)
                
                Text("Visible in tickets and chats")
                    .footnote()
                    .secondary()
            }
            
            Spacer()
            
            let uploading = isUploadingAvatar
            
            PhotosPicker(selection: $avatarPickerItem, matching: .images, photoLibrary: .shared()) {
                HStack(spacing: 6) {
                    if uploading {
                        ProgressView()
                    } else {
                        Image(systemName: "photo.on.rectangle.angled")
                    }
                    
                    Text(uploading ? "Updating..." : "Change")
                        .subheadline(.semibold)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.primary.opacity(0.08), lineWidth: 1)
                }
            }
            .disabled(isUploadingAvatar)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
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
                AsyncImage(url: url) { phase in
                    switch phase {
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

#Preview {
    BillingAccountSection(.preview)
        .darkSchemePreferred()
        .environment(BillingSettingsVM())
        .environment(BillingDashboardVM())
}
