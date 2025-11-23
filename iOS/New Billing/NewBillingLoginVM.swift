import Foundation

@Observable
final class NewBillingLoginVM {
    func login(login: String, password: String, captchaToken: String) async {
        let path = "https://test-api.bisquit.host/auth/signin"
        
        guard let url = URL(string: path) else {
            print("Invalid URL")
            return
        }
        
        let body = [
            "login": login.lowercased(),
            "password": password,
            "captchaResponse": captchaToken
        ]
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            
            if let jsonObject = try? JSONSerialization.jsonObject(with: data),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print(prettyString)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let response = try decoder.decode(BillingLoginResponse.self, from: data)
            print(response)
        } catch {
            print(error.localizedDescription)
        }
    }
}
