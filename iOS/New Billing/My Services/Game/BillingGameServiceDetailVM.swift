import Foundation

@Observable
final class BillingGameServiceDetailVM {
    var service: BillingGameServiceDetails?
    var changeablePackages: [BillingChangeableGamePackage] = []
    var isLoading = false
    var isPerformingAction = false
    var lastError: String?
    var actionMessage: String?
    
    private let base = URL(string: "https://test-api.bisquit.host")!
    
    func load(serviceId: Int) async {
        guard !isLoading else { return }
        
        isLoading = true
        lastError = nil
        actionMessage = nil
        
        defer { isLoading = false }
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchDetails(serviceId) }
            group.addTask { await self.fetchChangeablePackages(serviceId) }
        }
    }
    
    func fetchDetails(_ serviceId: Int) async {
        guard let data = await request(path: "/game/\(serviceId)") else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            service = try decoder.decode(BillingGameServiceDetails.self, from: data)
        } catch {
            lastError = error.localizedDescription
            print("Game detail decode error:", error)
            if let raw = String(data: data, encoding: .utf8) {
                print("Game raw detail:", raw)
            }
        }
    }
    
    func fetchChangeablePackages(_ serviceId: Int) async {
        guard let data = await request(path: "/game/\(serviceId)/change-package/packages") else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            changeablePackages = try decoder.decode([BillingChangeableGamePackage].self, from: data)
        } catch {
            lastError = error.localizedDescription
            print("Game changeable packages decode error:", error)
            if let raw = String(data: data, encoding: .utf8) {
                print("Game raw packages:", raw)
            }
        }
    }
    
    func rename(_ newName: String, serviceId: Int) async {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            lastError = "Enter a name"
            return
        }
        
        let body = ["name": trimmed]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard await self.request(path: "/game/\(serviceId)/name", method: "PATCH", body: payload) != nil else { return }
            
            if let current = self.service {
                self.service = BillingGameServiceDetails(
                    id: current.id,
                    name: trimmed,
                    price: current.price,
                    autorenew: current.autorenew,
                    state: current.state,
                    allowSuspend: current.allowSuspend,
                    allowDelete: current.allowDelete,
                    createdAt: current.createdAt,
                    expiresAt: current.expiresAt,
                    packageInfo: current.packageInfo,
                    location: current.location
                )
            }
        }
    }
    
    func changeAutorenew(_ enabled: Bool, serviceId: Int) async {
        let body = ["autorenew": enabled]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard await self.request(path: "/game/\(serviceId)/autorenew", method: "PATCH", body: payload) != nil else { return }
            if let current = self.service {
                self.service = BillingGameServiceDetails(
                    id: current.id,
                    name: current.name,
                    price: current.price,
                    autorenew: enabled,
                    state: current.state,
                    allowSuspend: current.allowSuspend,
                    allowDelete: current.allowDelete,
                    createdAt: current.createdAt,
                    expiresAt: current.expiresAt,
                    packageInfo: current.packageInfo,
                    location: current.location
                )
            }
            self.actionMessage = enabled ? "Auto-extend enabled" : "Auto-extend disabled"
        }
    }
    
    func renew(months: Int, serviceId: Int) async -> BillingServiceRenewResponse? {
        guard [1, 3, 6, 12].contains(months) else {
            lastError = "Unsupported period"
            return nil
        }
        
        let body = ["months": months]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return nil }
        
        return await withCheckedContinuation { continuation in
            Task {
                await self.performAction {
                    guard let data = await self.request(path: "/game/\(serviceId)/renew", method: "POST", body: payload) else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        let response = try decoder.decode(BillingServiceRenewResponse.self, from: data)
                        if let current = self.service {
                            self.service = BillingGameServiceDetails(
                                id: current.id,
                                name: current.name,
                                price: current.price,
                                autorenew: current.autorenew,
                                state: current.state,
                                allowSuspend: current.allowSuspend,
                                allowDelete: current.allowDelete,
                                createdAt: current.createdAt,
                                expiresAt: response.newExpiresAt,
                                packageInfo: current.packageInfo,
                                location: current.location
                            )
                        }
                        self.actionMessage = "Extended for \(months) mo."
                        continuation.resume(returning: response)
                    } catch {
                        self.lastError = error.localizedDescription
                        print("Game renew decode error:", error)
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
    
    func changePackage(to packageId: Int, serviceId: Int) async {
        let body = ["package": packageId]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard await self.request(path: "/game/\(serviceId)/change-package", method: "POST", body: payload) != nil else { return }
            self.actionMessage = "Upgrade requested"
            await self.fetchDetails(serviceId)
        }
    }
    
    // MARK: - Networking
    
    private func performAction(_ work: @escaping () async -> Void) async {
        guard !isPerformingAction else { return }
        
        isPerformingAction = true
        lastError = nil
        actionMessage = nil
        
        defer { isPerformingAction = false }
        
        await work()
    }
    
    private func request(path: String, method: String = "GET", body: Data? = nil) async -> Data? {
        let token = ValueStore().testAccessToken
        
        if token.isEmpty {
            lastError = "Missing session"
            print("Game request missing token")
            return nil
        }
        
        guard let url = URL(string: path, relativeTo: base) else {
            lastError = "Invalid URL"
            print("Game request invalid URL:", path)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                lastError = "No response"
                print("Game request no HTTP response")
                return nil
            }
            
            if http.statusCode == 204 {
                return Data()
            }
            
            guard (200...299).contains(http.statusCode) else {
                lastError = String(data: data, encoding: .utf8) ?? "Status \(http.statusCode)"
                print("Game request error \(http.statusCode):", lastError ?? "")
                return nil
            }
            
            return data
        } catch {
            lastError = error.localizedDescription
            print("Game request failed:", error)
            return nil
        }
    }
}
