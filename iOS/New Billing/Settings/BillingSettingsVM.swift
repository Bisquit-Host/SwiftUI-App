import Foundation

@Observable
final class BillingSettingsVM {
    var newLogin = ""
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
    
    func changeLogin(onSuccess: @escaping () async -> Void) async {
        let store = ValueStore()
        let path = "https://test-api.bisquit.host/user/settings/login"
        
        guard let url = URL(string: path) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(store.testAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["login": newLogin])
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let code = (response as? HTTPURLResponse)?.statusCode {
                switch code {
                case 200:
                    newLogin = ""
                    print("Successfully changed login")
                    await onSuccess()
                    
                default:
                    print(code)
                }
            }
        } catch {
            SystemAlert.error(error.localizedDescription)
        }
    }
    
    func changePassword(hasExistingPassword: Bool, onSuccess: @escaping () async -> Void) async {
        let trimmedNewPassword = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCurrentPassword = currentPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirmation = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if hasExistingPassword && trimmedCurrentPassword.isEmpty {
            SystemAlert.error("Enter current password")
            return
        }
        
        if trimmedNewPassword.isEmpty {
            SystemAlert.error("Enter new password")
            return
        }
        
        if trimmedNewPassword.count < 8 {
            SystemAlert.error("Password too short", subtitle: "Use at least 8 characters")
            return
        }
        
        if trimmedNewPassword.count > 70 {
            SystemAlert.error("Password too long", subtitle: "70 characters max")
            return
        }
        
        if trimmedNewPassword != trimmedConfirmation {
            SystemAlert.error("Passwords do not match")
            return
        }
        
        guard let url = URL(string: "https://test-api.bisquit.host/user/settings/password") else {
            SystemAlert.error("Invalid URL")
            return
        }
        
        let token = ValueStore().testAccessToken
        if token.isEmpty {
            SystemAlert.error("Missing session", subtitle: "Sign in again")
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
                SystemAlert.error("No response")
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
    
    func updateAvatar(with data: Data, filename: String, mimeType: String?) async -> String? {
        guard let mimeType else {
            SystemAlert.error("Invalid mimetype")
            return nil
        }
        
        guard let url = URL(string: "https://test-api.bisquit.host/user/settings/avatar") else {
            SystemAlert.error("Invalid URL")
            return nil
        }
        
        let token = ValueStore().testAccessToken
        
        if token.isEmpty {
            SystemAlert.error("Missing session")
            return nil
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.assumesHTTP3Capable = false
        
        let config = URLSessionConfiguration.ephemeral
        
        var headers = config.httpAdditionalHeaders ?? [:]
        headers["Alt-Svc"] = "clear"
        
        config.httpAdditionalHeaders = headers
        
        let session = URLSession(configuration: config)
        let body = makeMultipartBody(data: data, filename: filename, mimeType: mimeType, boundary: boundary)
        
        print("Uploading file", filename, "of type", mimeType)
        
        do {
            let (data, response) = try await session.upload(for: request, from: body)
            
            guard let http = response as? HTTPURLResponse else {
                SystemAlert.error("No response")
                return nil
            }
            
            print("Status code for", #function, http.statusCode)
            
            switch http.statusCode {
            case 200:
                if let result = try? JSONDecoder().decode(AvatarUpdateResponse.self, from: data) {
                    return result.avatar
                } else {
                    SystemAlert.error("Bad response")
                }
                
            default:
                if let raw = String(data: data, encoding: .utf8), !raw.isEmpty {
                    SystemAlert.error(raw)
                } else {
                    SystemAlert.error("Status \(http.statusCode)")
                }
            }
        } catch {
            SystemAlert.error(error.localizedDescription)
        }
        
        return nil
    }
    
    private func makeMultipartBody(data: Data, filename: String, mimeType: String, boundary: String) -> Data {
        var body = Data()
        let disposition = "Content-Disposition: form-data; name=\"avatar\"; filename=\"\(filename)\"\r\n"
        
        body.append("--\(boundary)\r\n")
        body.append(disposition)
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        return body
    }
}

fileprivate extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
