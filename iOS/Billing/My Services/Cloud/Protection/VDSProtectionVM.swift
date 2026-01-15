import SwiftUI
import BisquitoNet
import PteroNet

@Observable
final class VDSProtectionVM {
    var ipInfo: VDSProtectionIPInfo?
    var presets: [VDSProtectionPreset] = []
    var profiles: [VDSProtectionProfile] = []
    var attacks: [VDSProtectionAttack] = []
    
    var isLoading = false
    var isLoadingAttacks = false
    var isPerformingAction = false
    var canLoadMoreAttacks = true
    
    private var serviceId: Int?
    private var attacksPage = 1
    
    func load(_ serviceId: Int) async {
        guard !isLoading else { return }
        self.serviceId = serviceId
        
        isLoading = true
        
        defer {
            withAnimation {
                isLoading = false
            }
        }
        
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
        guard let accessToken = accessToken() else { return }
        
        guard let ipInfo = await vdsProtectionIPAPI(
            serviceId: serviceId,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) else { return }
        
        self.ipInfo = ipInfo
    }
    
    func fetchPresets(_ serviceId: Int) async {
        guard let accessToken = accessToken() else { return }
        
        guard let presets = await vdsProtectionPresetsAPI(
            serviceId: serviceId,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) else { return }
        
        self.presets = presets
    }
    
    func fetchProfiles(_ serviceId: Int) async {
        guard let accessToken = accessToken() else { return }
        
        guard let profiles = await vdsProtectionProfilesAPI(
            serviceId: serviceId,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) else { return }
        
        self.profiles = profiles
    }
    
    func fetchAttacks(_ serviceId: Int, page: Int, reset: Bool) async {
        guard !isLoadingAttacks else { return }
        guard let accessToken = accessToken() else { return }
        
        isLoadingAttacks = true
        defer { isLoadingAttacks = false }
        
        guard let decoded = await vdsProtectionAttacksAPI(
            serviceId: serviceId,
            page: page,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) else { return }
        
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
    }
    
    func loadMoreAttacks() async {
        guard let serviceId, canLoadMoreAttacks else { return }
        
        let next = attacksPage + 1
        await fetchAttacks(serviceId, page: next, reset: false)
    }
    
    func updateDefaultAction(_ action: VDSProtectionDefaultAction) async {
        guard action.isUpdatable, let serviceId else { return }
        guard let accessToken = accessToken() else { return }
        
        let body = ["defaultAction": action.rawValue]
        guard let payload = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        await performAction {
            let result = await vdsProtectionUpdateDefaultActionAPI(
                serviceId: serviceId,
                payload: payload,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            )
            
            guard result.didSucceed else { return }
            
            if let updated = result.value {
                self.ipInfo = updated
            } else {
                self.ipInfo?.defaultAction = action
            }
        }
    }
    
    func createProfile(_ input: VDSProtectionProfileInput) async {
        guard let serviceId else { return }
        guard let accessToken = accessToken() else { return }
        
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
            let result = await vdsProtectionCreateProfileAPI(
                serviceId: serviceId,
                payload: payload,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            )
            
            guard result.didSucceed else { return }
            
            if let created = result.value {
                self.profiles.insert(created, at: 0)
            } else {
                await self.fetchProfiles(serviceId)
            }
        }
    }
    
    func updateProfile(_ profileId: Int, input: VDSProtectionProfileInput) async {
        guard let serviceId else { return }
        guard let accessToken = accessToken() else { return }
        
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
            let result = await vdsProtectionUpdateProfileAPI(
                serviceId: serviceId,
                profileId: profileId,
                payload: payload,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            )
            
            guard result.didSucceed else { return }
            
            if let updated = result.value {
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
        guard let accessToken = accessToken() else { return }
        
        await performAction {
            guard await vdsProtectionDeleteProfileAPI(
                serviceId: serviceId,
                profileId: profileId,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) else { return }
            
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
}
