import ScrechKit
import Kingfisher

struct CredentialsView: View {
    private var vm = CredentialsVM()
    @Environment(\.dismiss) private var dismiss
    
    private let whatToUpdate: String
    
    init(_ whatToUpdate: String) {
        self.whatToUpdate = whatToUpdate
    }
    
    @State private var email = ""
    @State private var password = ""
    @State private var newPassword = ""
    @State private var newPasswordAgain = ""
    
    var body: some View {
        VStack {
            Text(whatToUpdate == "email" ? String(localized: "Update email") : String(localized: "Update password"))
                .title2()
                .padding(.top)
            
            switch whatToUpdate {
            case "email":
                CredentialField(text: email, hint: "New email", isSecure: false, textType: .emailAddress, keyboardType: .emailAddress)
                CredentialField(text: password, hint: "Password", isSecure: true, textType: .password)
                
            case "password":
                CredentialField(text: password, hint: "Current password", isSecure: true, textType: .password)
                CredentialField(text: newPassword, hint: "New password", isSecure: false, textType: .newPassword)
                CredentialField(text: newPassword, hint: "Confirm new password", isSecure: false, textType: .newPassword)
                
            default: ProgressView()
            }
            
            HStack {
                Spacer()
                
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                
                Spacer()
                
                Button("Update", role: .destructive, action: update)
                
                Spacer()
            }
            .padding(.vertical, 10)
            
            Spacer()
            
            KFImage(getImageURL("streamer"))
                .resizable()
                .fade(duration: 0.25)
                .aspectRatio(3/2, contentMode: .fit)
                .padding(.leading)
        }
        .presentationDetents([.medium])
        .monospaced()
        .ignoresSafeArea()
        .multilineTextAlignment(.center)
    }
    
    private func getImageURL(_ imageName: String) -> URL {
        let stringURL = "https://topscrech.dev/bisquit.host/assets/\(imageName).heic"
        
        guard let url = URL(string: stringURL) else {
            fatalError("Failed to create URL from string: \(stringURL)")
        }
        
        return url
    }
    
    private func update() {
        Task {
            switch whatToUpdate {
            case "email":
                await vm.updateCredentials(
                    type: .email(
                        email: email,
                        password: password
                    )
                )
                
            case "password":
                await vm.updateCredentials(
                    type: .password(
                        currentPassword: password,
                        newPassword: newPassword,
                        passwordConfirmation: newPasswordAgain
                    )
                )
                
            default: break
            }
        }
    }
}

#Preview {
    CredentialsView("email")
        .darkSchemePreferred()
}
