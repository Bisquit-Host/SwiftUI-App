import Foundation

@Observable
final class BillingSettingsVM {
    var newName = ""
    var newEmail = ""
    
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
                    
                default:
                    print(code)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
