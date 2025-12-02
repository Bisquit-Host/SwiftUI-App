import Foundation

@Observable
final class BillingSettingsVM {
    var newName = ""
    var newEmail = ""
    var currentPassword = ""
    var newPassword = ""
    var confirmPassword = ""
    var isUpdatingPassword = false
    
    func changeName(onSuccess: @escaping () async -> Void) async {
        let store = ValueStore()
        let path = "https://test-api.bisquit.host/user/settings/name"
        
        guard let url = URL(string: path) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(store.testAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["name": newName])
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let code = (response as? HTTPURLResponse)?.statusCode {
                switch code {
                case 200:
                    newName = ""
                    print("Successfully changed name")
                    await onSuccess()
                    
                default:
                    print(code)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func changeEmail() async {
        let store = ValueStore()
        let path = "https://test-api.bisquit.host/user/settings/email"
        
        guard let url = URL(string: path) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(store.testAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["email": newEmail])
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let code = (response as? HTTPURLResponse)?.statusCode {
                switch code {
                case 200:
                    newEmail = ""
                    print("Successfully changed email")
                    SystemAlert.copied("Chck your email")
                    
                default:
                    print(code)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func changePassword(hasExistingPassword: Bool, onSuccess: @escaping () async -> Void) async {
        let trimmedNewPassword = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCurrentPassword = currentPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirmation = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        if hasExistingPassword && trimmedCurrentPassword.isEmpty {
            SystemAlert.error("Enter current password", subtitle: nil)
            return
        }

        if trimmedNewPassword.isEmpty {
            SystemAlert.error("Enter new password", subtitle: nil)
            return
        }

        if trimmedNewPassword.count < 8 {
            SystemAlert.error("Password too short", subtitle: "Use at least 8 characters.")
            return
        }

        if trimmedNewPassword.count > 70 {
            SystemAlert.error("Password too long", subtitle: "70 characters max.")
            return
        }

        if trimmedNewPassword != trimmedConfirmation {
            SystemAlert.error("Passwords do not match", subtitle: nil)
            return
        }

        guard let url = URL(string: "https://test-api.bisquit.host/user/settings/password") else {
            SystemAlert.error("Invalid URL", subtitle: nil)
            return
        }

        let token = ValueStore().testAccessToken
        if token.isEmpty {
            SystemAlert.error("Missing session", subtitle: "Sign in again.")
            return
        }

        isUpdatingPassword = true
        defer { isUpdatingPassword = false }

        var request = URLRequest(url: url)
        request.httpMethod = hasExistingPassword ? "PATCH" : "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        if hasExistingPassword {
            request.httpBody = try? JSONEncoder().encode([
                "oldPassword": trimmedCurrentPassword,
                "newPassword": trimmedNewPassword
            ])
        } else {
            request.httpBody = try? JSONEncoder().encode([
                "password": trimmedNewPassword
            ])
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                SystemAlert.error("No response", subtitle: nil)
                return
            }

            switch http.statusCode {
            case 200, 201, 204:
                resetPasswordFields()
                await onSuccess()
                SystemAlert.copied("Password updated")

            default:
                if let raw = String(data: data, encoding: .utf8), !raw.isEmpty {
                    SystemAlert.error("Failed to update", subtitle: raw)
                } else {
                    SystemAlert.error("Failed to update", subtitle: "Status \(http.statusCode)")
                }
            }
        } catch {
            SystemAlert.error("Error", subtitle: error.localizedDescription)
        }
    }

    func resetPasswordFields() {
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
}
