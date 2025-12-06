import Foundation

@Observable
final class BillingCloudServiceDetailVM {
    var service: BillingCloudServiceDetails?
    var history: [BillingCloudHistoryItem] = []
    var charts: BillingCloudCharts?
    var osOptions: [BillingCloudOsCategory] = []
    var changeablePackages: [BillingChangeableCloudPackage] = []
    
    var isLoading = false
    var isPerformingAction = false
    var lastError: String?
    var actionMessage: String?
    
    private let base = URL(string: "https://test-api.bisquit.host")!
    
    func load(_ serviceId: Int) async {
        guard !isLoading else { return }
        
        isLoading = true
        lastError = nil
        actionMessage = nil
        
        defer {
            isLoading = false
        }
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchDetails(serviceId) }
            group.addTask { await self.fetchHistory(serviceId) }
            group.addTask { await self.fetchCharts(serviceId) }
            group.addTask { await self.fetchOsOptions(serviceId) }
            group.addTask { await self.fetchChangeablePackages(serviceId) }
        }
    }
    
    func fetchDetails(_ serviceId: Int) async {
        guard let data = await request(path: "/cloud/\(serviceId)") else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            service = try decoder.decode(BillingCloudServiceDetails.self, from: data)
        } catch {
            SystemAlert.error("Cloud detail decode error: \(error)")
            
            if let raw = String(data: data, encoding: .utf8) {
                print("Raw detail:", raw)
            }
        }
    }
    
    func fetchChangeablePackages(_ serviceId: Int) async {
        guard let data = await request(path: "/cloud/\(serviceId)/change-package/packages") else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            changeablePackages = try decoder.decode([BillingChangeableCloudPackage].self, from: data)
        } catch {
            SystemAlert.error("Cloud changeable packages decode error: \(error)")
            
            if let raw = String(data: data, encoding: .utf8) {
                print("Raw packages:", raw)
            }
        }
    }
    
    func fetchHistory(_ serviceId: Int) async {
        guard let data = await request(path: "/cloud/\(serviceId)/panel/history") else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            history = try decoder.decode([BillingCloudHistoryItem].self, from: data)
        } catch {
            SystemAlert.error("Cloud history decode error: \(error)")
            
            if let raw = String(data: data, encoding: .utf8) {
                print("Raw history:", raw)
            }
        }
    }
    
    func fetchCharts(_ serviceId: Int) async {
        guard let data = await request(path: "/cloud/\(serviceId)/panel/charts") else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            charts = try decoder.decode(BillingCloudCharts.self, from: data)
        } catch {
            SystemAlert.error("Cloud charts decode error: \(error)")
            
            if let raw = String(data: data, encoding: .utf8) {
                print("Raw charts:", raw)
            }
        }
    }
    
    func fetchOsOptions(_ serviceId: Int) async {
        guard let data = await request(path: "/cloud/\(serviceId)/panel/reinstall/os") else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            osOptions = try decoder.decode([BillingCloudOsCategory].self, from: data)
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
            lastError = "Enter a name"
            return
        }
        
        let body = ["name": trimmed]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard await self.request(path: "/cloud/\(serviceId)/name", method: "PATCH", body: payload) != nil else { return }
            
            if let current = self.service {
                self.service = BillingCloudServiceDetails(
                    id: current.id,
                    name: trimmed,
                    price: current.price,
                    autorenew: current.autorenew,
                    state: current.state,
                    allowSuspend: current.allowSuspend,
                    allowDelete: current.allowDelete,
                    createdAt: current.createdAt,
                    expiresAt: current.expiresAt,
                    ip: current.ip,
                    vmId: current.vmId,
                    password: current.password,
                    system: current.system,
                    ptrRecord: current.ptrRecord,
                    packageInfo: current.packageInfo,
                    location: current.location
                )
            }
            
            self.actionMessage = "Name updated"
        }
    }
    
    func changePassword(_ password: String, serviceId: Int) async {
        let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmed.count >= 8, trimmed.count <= 32 else {
            lastError = "Password must be 8-32 characters"
            return
        }
        
        let body = ["password": trimmed]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard await self.request(path: "/cloud/\(serviceId)/panel/password", method: "PATCH", body: payload) != nil else { return }
            self.actionMessage = "Root password updated"
        }
    }
    
    func reinstall(osId: Int, serviceId: Int) async {
        let body = ["os": osId]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard await self.request(path: "/cloud/\(serviceId)/panel/reinstall", method: "POST", body: payload) != nil else { return }
            self.actionMessage = "Reinstall started"
        }
    }
    
    func changeAutorenew(_ enabled: Bool, serviceId: Int) async {
        let body = ["autorenew": enabled]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard await self.request(path: "/cloud/\(serviceId)/autorenew", method: "PATCH", body: payload) != nil else { return }
            
            if let current = self.service {
                self.service = BillingCloudServiceDetails(
                    id: current.id,
                    name: current.name,
                    price: current.price,
                    autorenew: enabled,
                    state: current.state,
                    allowSuspend: current.allowSuspend,
                    allowDelete: current.allowDelete,
                    createdAt: current.createdAt,
                    expiresAt: current.expiresAt,
                    ip: current.ip,
                    vmId: current.vmId,
                    password: current.password,
                    system: current.system,
                    ptrRecord: current.ptrRecord,
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
                    guard let data = await self.request(path: "/cloud/\(serviceId)/renew", method: "POST", body: payload) else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        let response = try decoder.decode(BillingServiceRenewResponse.self, from: data)
                        if let current = self.service {
                            self.service = BillingCloudServiceDetails(
                                id: current.id,
                                name: current.name,
                                price: current.price,
                                autorenew: current.autorenew,
                                state: current.state,
                                allowSuspend: current.allowSuspend,
                                allowDelete: current.allowDelete,
                                createdAt: current.createdAt,
                                expiresAt: response.newExpiresAt,
                                ip: current.ip,
                                vmId: current.vmId,
                                password: current.password,
                                system: current.system,
                                ptrRecord: current.ptrRecord,
                                packageInfo: current.packageInfo,
                                location: current.location
                            )
                        }
                        
                        self.actionMessage = "Extended for \(months) mo"
                        continuation.resume(returning: response)
                    } catch {
                        self.lastError = error.localizedDescription
                        print("Cloud renew decode error:", error)
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
            guard await self.request(path: "/cloud/\(serviceId)/change-package", method: "POST", body: payload) != nil else { return }
            
            self.actionMessage = "Upgrade requested"
            await self.fetchDetails(serviceId)
        }
    }
    
    func power(_ action: String, serviceId: Int) async {
        guard ["start", "stop", "restart"].contains(action) else { return }
        
        await performAction {
            guard let data = await self.request(path: "/cloud/\(serviceId)/panel/state/\(action)", method: "POST") else {
                print("Power action \(action) failed:", self.lastError ?? "unknown error")
                return
            }
            
            if let raw = String(data: data, encoding: .utf8), !raw.isEmpty {
                print("Power action response:", raw)
            }
            
            self.actionMessage = "Action sent: \(action.capitalized)"
        }
    }
    
    // MARK: - Networking
    private func performAction(_ work: @escaping () async -> Void) async {
        guard !isPerformingAction else { return }
        
        isPerformingAction = true
        lastError = nil
        actionMessage = nil
        
        defer {
            isPerformingAction = false
        }
        
        await work()
    }
    
    private func request(path: String, method: String = "GET", body: Data? = nil) async -> Data? {
        let token = ValueStore().testAccessToken
        
        if token.isEmpty {
            lastError = "Missing session"
            print("Cloud request missing token")
            return nil
        }
        
        guard let url = URL(string: path, relativeTo: base) else {
            lastError = "Invalid URL"
            print("Cloud request invalid URL:", path)
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
                print("Cloud request no HTTP response")
                return nil
            }
            
            if http.statusCode == 204 {
                return Data()
            }
            
            guard (200...299).contains(http.statusCode) else {
                lastError = String(data: data, encoding: .utf8) ?? "Status \(http.statusCode)"
                print("Cloud request error \(http.statusCode):", lastError ?? "")
                return nil
            }
            
            return data
        } catch {
            lastError = error.localizedDescription
            print("Cloud request failed:", error)
            return nil
        }
    }
}
