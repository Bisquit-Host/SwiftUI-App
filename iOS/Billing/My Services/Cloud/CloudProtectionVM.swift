import Foundation
import PteroNet

@Observable
final class CloudProtectionVM {
    var ipInfo: CloudProtectionIPInfo?
    var presets: [CloudProtectionPreset] = []
    var profiles: [CloudProtectionProfile] = []
    var attacks: [CloudProtectionAttack] = []
    
    var isLoading = false
    var isLoadingAttacks = false
    var isPerformingAction = false
    var canLoadMoreAttacks = true
    
    private var serviceId: Int?
    private var attacksPage = 1
    private let base = URL(string: "https://test-api.bisquit.host")!
    
    func load(_ serviceId: Int) async {
        guard !isLoading else { return }
        self.serviceId = serviceId
        isLoading = true
        defer { isLoading = false }
        
        attacksPage = 1
        canLoadMoreAttacks = true
        attacks = []
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchIP(serviceId) }
            group.addTask { await self.fetchPresets(serviceId) }
            group.addTask { await self.fetchProfiles(serviceId) }
            group.addTask { await self.fetchAttacks(serviceId, page: 1, reset: true) }
        }
    }
    
    func fetchIP(_ serviceId: Int) async {
        guard let data = await request(path: "/cloud/\(serviceId)/protection/ip") else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            ipInfo = try decoder.decode(CloudProtectionIPInfo.self, from: data)
        } catch {
            SystemAlert.error("Protection IP decode error: \(error)")
        }
    }
    
    func fetchPresets(_ serviceId: Int) async {
        guard let data = await request(path: "/cloud/\(serviceId)/protection/presets") else { return }
        
        do {
            presets = try JSONDecoder().decode([CloudProtectionPreset].self, from: data)
        } catch {
            SystemAlert.error("Protection presets decode error: \(error)")
        }
    }
    
    func fetchProfiles(_ serviceId: Int) async {
        guard let data = await request(path: "/cloud/\(serviceId)/protection/profiles") else { return }
        
        do {
            profiles = try JSONDecoder().decode([CloudProtectionProfile].self, from: data)
        } catch {
            SystemAlert.error("Protection profiles decode error: \(error)")
        }
    }
    
    func fetchAttacks(_ serviceId: Int, page: Int, reset: Bool) async {
        guard !isLoadingAttacks else { return }
        
        isLoadingAttacks = true
        defer { isLoadingAttacks = false }
        
        guard let data = await request(path: "/cloud/\(serviceId)/protection/attacks?page=\(page)") else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let decoded = try decoder.decode([CloudProtectionAttack].self, from: data)
            
            if reset {
                attacks = decoded
                attacksPage = 1
            } else {
                attacks.append(contentsOf: decoded)
                attacksPage = page
            }
            
            if decoded.isEmpty {
                canLoadMoreAttacks = false
            }
        } catch {
            SystemAlert.error("Protection attacks decode error: \(error)")
        }
    }
    
    func loadMoreAttacks() async {
        guard let serviceId, canLoadMoreAttacks else { return }
        let next = attacksPage + 1
        await fetchAttacks(serviceId, page: next, reset: false)
    }
    
    func updateDefaultAction(_ action: CloudProtectionDefaultAction) async {
        guard action.isUpdatable, let serviceId else { return }
        let body = ["defaultAction": action.rawValue]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard let data = await self.request(path: "/cloud/\(serviceId)/protection/ip", method: "PATCH", body: payload) else { return }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if let updated = try? decoder.decode(CloudProtectionIPInfo.self, from: data) {
                self.ipInfo = updated
            } else {
                self.ipInfo?.defaultAction = action
            }
        }
    }
    
    func createProfile(_ input: CloudProtectionProfileInput) async {
        guard let serviceId else { return }
        
        var body: [String: Any] = [
            "presetId": input.presetId,
            "protocol": input.`protocol`.rawValue
        ]
        
        if let minPort = input.minPort { body["minDstPort"] = minPort }
        if let maxPort = input.maxPort { body["maxDstPort"] = maxPort }
        
        if let notes = input.notes?.trimmingCharacters(in: .whitespacesAndNewlines), !notes.isEmpty {
            body["notes"] = notes
        }
        
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard let data = await self.request(path: "/cloud/\(serviceId)/protection/profiles", method: "POST", body: payload) else { return }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if let created = try? decoder.decode(CloudProtectionProfile.self, from: data) {
                self.profiles.insert(created, at: 0)
            } else {
                await self.fetchProfiles(serviceId)
            }
        }
    }
    
    func updateProfile(_ profileId: Int, input: CloudProtectionProfileInput) async {
        guard let serviceId else { return }
        
        var body: [String: Any] = [
            "presetId": input.presetId,
            "protocol": input.`protocol`.rawValue
        ]
        
        if let minPort = input.minPort { body["minDstPort"] = minPort }
        if let maxPort = input.maxPort { body["maxDstPort"] = maxPort }
        
        if let notes = input.notes?.trimmingCharacters(in: .whitespacesAndNewlines), !notes.isEmpty {
            body["notes"] = notes
        }
        
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            guard let data = await self.request(path: "/cloud/\(serviceId)/protection/profiles/\(profileId)", method: "PUT", body: payload) else { return }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if let updated = try? decoder.decode(CloudProtectionProfile.self, from: data) {
                if let index = self.profiles.firstIndex(where: { $0.id == profileId }) {
                    self.profiles[index] = updated
                } else {
                    self.profiles.insert(updated, at: 0)
                }
            } else {
                await self.fetchProfiles(serviceId)
            }
        }
    }
    
    func deleteProfile(_ profileId: Int) async {
        guard let serviceId else { return }
        
        await performAction {
            guard await self.request(path: "/cloud/\(serviceId)/protection/profiles/\(profileId)", method: "DELETE") != nil else { return }
            
            self.profiles.removeAll { $0.id == profileId }
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
            print("Protection request invalid URL:", path)
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
                print("Protection request no HTTP response")
                return nil
            }
            
            if http.statusCode == 204 {
                return Data()
            }
            
            guard (200...299).contains(http.statusCode) else {
                let error = String(data: data, encoding: .utf8) ?? "Status \(http.statusCode)"
                
                SystemAlert.error(error)
                print("Protection request error \(http.statusCode):", error)
                return nil
            }
            
            return data
        } catch {
            SystemAlert.error(error.localizedDescription)
            print("Protection request failed:", error)
            return nil
        }
    }
}
