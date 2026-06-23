import Calagopus

@Observable
final class CredentialsVM {
    func updateCredentials(type: UpdateType) async {
        do {
            let client = try CalagopusClientFactory.client()
            
            switch type {
            case .email(let email, let password):
                try await client.updateEmail(email, password: password)
            case .password(let currentPassword, let newPassword, _):
                try await client.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
            }
        } catch {
            SystemAlert.error(error)
        }
    }
}

enum UpdateType: Sendable {
    case email(email: String, password: String)
    
    case password(
        currentPassword: String,
        newPassword: String,
        passwordConfirmation: String
    )
}
