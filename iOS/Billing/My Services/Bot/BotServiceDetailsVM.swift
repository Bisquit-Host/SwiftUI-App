import Foundation
import PteroNet

@Observable
final class BotServiceDetailsVM {
    var service: BillingServiceDetails?
    var changeablePackages: [ChangeablePackage] = []
    var isLoading = false
    var isPerformingAction = false
    
    private let base = URL(string: "https://test-api.bisquit.host")!
    
    func load(_ serviceId: Int) async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchDetails(serviceId) }
            
            if service?.state != .suspended && service?.state != .deleted {
                group.addTask { await self.fetchChangeablePackages(serviceId) }
            }
        }
    }
    
    func fetchDetails(_ serviceId: Int) async {
        guard let data = await request(path: "/bot/\(serviceId)") else { return }
        
        do {
            service = try BigAssDecoder.decode(BillingServiceDetails.self, from: data)
        } catch {
            SystemAlert.error("Bot detail decode error: \(error)")
            
            if let raw = String(data: data, encoding: .utf8) {
                print("Bot raw detail:", raw)
            }
        }
    }
    
    func fetchChangeablePackages(_ serviceId: Int) async {
        guard let data = await request(path: "/bot/\(serviceId)/change-package/packages") else { return }
        
        do {
            changeablePackages = try BigAssDecoder.decode([ChangeablePackage].self, from: data)
        } catch {
            SystemAlert.error("Bot changeable packages decode error: \(error)")
            
            if let raw = String(data: data, encoding: .utf8) {
                print("Bot raw packages:", raw)
            }
        }
    }
    
    func rename(_ newName: String, serviceId: Int) async {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            SystemAlert.error("Enter a name")
            return
        }
        
        let body = ["name": trimmed]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard await self.request(path: "/bot/\(serviceId)/name", method: "PATCH", body: payload) != nil else { return }
            
            self.service?.name = trimmed
        }
    }
    
    func changeAutorenew(_ enabled: Bool, serviceId: Int) async {
        let body = ["autorenew": enabled]
        
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard await self.request(path: "/bot/\(serviceId)/autorenew", method: "PATCH", body: payload) != nil else { return }
            
            self.service?.autorenew = enabled
            SystemAlert.done(enabled ? "Auto-renew enabled" : "Auto-renew disabled")
        }
    }
    
    func renew(months: Int, serviceId: Int) async -> ServiceRenewalResponse? {
        guard [1, 3, 6, 12].contains(months) else {
            SystemAlert.error("Unsupported period")
            return nil
        }
        
        let body = ["months": months]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return nil }
        
        return await withCheckedContinuation { continuation in
            Task {
                await self.performAction {
                    guard let data = await self.request(path: "/bot/\(serviceId)/renew", method: "POST", body: payload) else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    do {
                        let response = try BigAssDecoder.decode(ServiceRenewalResponse.self, from: data)
                        
                        self.service?.expiresAt = response.newExpiresAt
                        
                        SystemAlert.done("Renewed for \(months) mo")
                        continuation.resume(returning: response)
                    } catch {
                        SystemAlert.error(error.localizedDescription)
                        print("Bot renewal decode error:", error)
                        
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
    
    func changePackage(to packageId: Int, serviceId: Int, onSuccess: @escaping () -> Void) async {
        let body = ["package": packageId]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard await self.request(path: "/bot/\(serviceId)/change-package", method: "POST", body: payload) != nil else { return }
            onSuccess()
            
            print("Upgrade requested")
            await self.fetchDetails(serviceId)
        }
    }
    
    // MARK: - Networking
    
    private func performAction(_ work: @escaping () async -> Void) async {
        guard !isPerformingAction else { return }
        
        isPerformingAction = true
        defer { isPerformingAction = false }
        
        await work()
    }
    
    private func request(path: String, method: String = "GET", body: Data? = nil) async -> Data? {
        guard let accessToken = Keychain.load(key: "access_token") else {
            print("Access token not found", #function)
            return nil
        }
        
        guard let url = URL(string: path, relativeTo: base) else {
            SystemAlert.error("Invalid URL")
            print("Bot request invalid URL:", path)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                SystemAlert.error("No response")
                print("Bot request no HTTP response")
                return nil
            }
            
            if http.statusCode == 204 {
                return Data()
            }
            
            guard (200...299).contains(http.statusCode) else {
                let error = String(data: data, encoding: .utf8) ?? "Status \(http.statusCode)"
                
                if let decodedError = try? BigAssDecoder.decode(PurchaseErrorResponse.self, from: data) {
                    SystemAlert.error(decodedError.title, subtitle: "Status code: \(decodedError.status)")
                } else {
                    SystemAlert.error(error, subtitle: "Status code: \(http.statusCode)")
                }
                
                return nil
            }
            
            return data
        } catch {
            SystemAlert.error(error.localizedDescription)
            print("Bot request failed:", error)
            
            return nil
        }
    }
}
