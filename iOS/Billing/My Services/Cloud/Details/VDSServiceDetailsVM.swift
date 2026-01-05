import Foundation
import PteroNet

@Observable
final class VDSServiceDetailsVM {
    var service: CloudServiceDetails?
    var history: [CloudServiceHistoryItem] = []
    var charts: CloudServiceCharts?
    var osOptions: [CloudServiceOSCategory] = []
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
            group.addTask { await self.fetchHistory(serviceId) }
            group.addTask { await self.fetchCharts(serviceId) }
            group.addTask { await self.fetchOSOptions(serviceId) }
            
            if service?.state != .suspended && service?.state != .deleted {
                group.addTask { await self.fetchChangeablePackages(serviceId) }
            }
        }
    }
    
    func fetchDetails(_ serviceId: Int) async {
        guard let data = await request(path: "/cloud/\(serviceId)") else { return }
        
        do {
            service = try BigAssDecoder.decode(CloudServiceDetails.self, from: data)
        } catch {
            SystemAlert.error("Cloud detail decode error: \(error)")
            
            if let raw = String(data: data, encoding: .utf8) {
                print("Raw detail:", raw)
            }
        }
    }
    
    func fetchChangeablePackages(_ serviceId: Int) async {
        guard let data = await request(path: "/cloud/\(serviceId)/change-package/packages") else { return }
        
        do {
            changeablePackages = try BigAssDecoder.decode([ChangeablePackage].self, from: data)
        } catch {
            SystemAlert.error("Cloud changeable packages decode error: \(error)")
            
            if let raw = String(data: data, encoding: .utf8) {
                print("Raw packages:", raw)
            }
        }
    }
    
    func fetchHistory(_ serviceId: Int) async {
        guard let data = await request(path: "/cloud/\(serviceId)/panel/history") else { return }
        
        do {
            history = try BigAssDecoder.decode([CloudServiceHistoryItem].self, from: data)
        } catch {
            SystemAlert.error("Cloud history decode error: \(error)")
            
            if let raw = String(data: data, encoding: .utf8) {
                print("Raw history:", raw)
            }
        }
    }
    
    func fetchCharts(_ serviceId: Int) async {
        guard let data = await request(path: "/cloud/\(serviceId)/panel/charts") else { return }
        
        do {
            charts = try BigAssDecoder.decode(CloudServiceCharts.self, from: data)
        } catch {
            SystemAlert.error("Cloud charts decode error: \(error)")
            
            if let raw = String(data: data, encoding: .utf8) {
                print("Raw charts:", raw)
            }
        }
    }
    
    func fetchOSOptions(_ serviceId: Int) async {
        guard let data = await request(path: "/cloud/\(serviceId)/panel/reinstall/os") else { return }
        
        do {
            osOptions = try BigAssDecoder.decode([CloudServiceOSCategory].self, from: data)
        } catch {
            SystemAlert.error("Cloud OS list decode error: \(error)")
            
            if let raw = String(data: data, encoding: .utf8) {
                print("Raw OS list:", raw)
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
            guard await self.request(path: "/cloud/\(serviceId)/name", method: "PATCH", body: payload) != nil else { return }
            
            self.service?.name = trimmed
            SystemAlert.done("Name updated")
        }
    }
    
    func changePassword(_ password: String, for serviceId: Int) async {
        let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmed.count >= 8, trimmed.count <= 32 else {
            SystemAlert.error("Password must be 8-32 characters, \"\(password)\" doesn't fit")
            return
        }
        
        let body = ["password": trimmed]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard await self.request(path: "/cloud/\(serviceId)/panel/password", method: "PATCH", body: payload) != nil else { return }
            SystemAlert.done("Root password updated")
        }
    }
    
    func reinstall(osId: Int, serviceId: Int) async {
        let body = ["os": osId]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard await self.request(path: "/cloud/\(serviceId)/panel/reinstall", method: "POST", body: payload) != nil else { return }
            print("Reinstall started")
        }
    }
    
    func changeAutorenew(_ enabled: Bool, serviceId: Int) async {
        let body = ["autorenew": enabled]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard await self.request(path: "/cloud/\(serviceId)/autorenew", method: "PATCH", body: payload) != nil else { return }
            
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
                    guard let data = await self.request(path: "/cloud/\(serviceId)/renew", method: "POST", body: payload) else {
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
                        print("Cloud renewal decode error:", error)
                        
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
            guard await self.request(path: "/cloud/\(serviceId)/change-package", method: "POST", body: payload) != nil else { return }
            onSuccess()
            
            print("Upgrade requested")
            await self.fetchDetails(serviceId)
        }
    }
    
    func power(_ action: String, serviceId: Int) async {
        guard ["start", "stop", "restart"].contains(action) else { return }
        
        await performAction {
            guard let data = await self.request(path: "/cloud/\(serviceId)/panel/state/\(action)", method: "POST") else {
                print("Power action \(action) failed")
                return
            }
            
            if let raw = String(data: data, encoding: .utf8), !raw.isEmpty {
                print("Power action response:", raw)
            }
            
            print("Action sent: \(action.capitalized)")
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
            print("Cloud request invalid URL:", path)
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
                print("Cloud request no HTTP response")
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
            print("Cloud request failed:", error)
            
            return nil
        }
    }
}
