import Foundation
import BisquitoNet
import PteroNet

@Observable
final class BotServiceDetailsVM {
    var service: BillingServiceDetails?
    var changeablePackages: [ChangeablePackage] = []
    var isLoading = false
    var isPerformingAction = false
    
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
        guard let accessToken = accessToken() else { return }
        guard let data = await botServiceDetailsAPI(
            serviceId: serviceId,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) else { return }
        
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
        guard let accessToken = accessToken() else { return }
        
        guard let data = await botServiceChangeablePackagesAPI(
            serviceId: serviceId,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) else { return }
        
        do {
            changeablePackages = try BigAssDecoder.decode([ChangeablePackage].self, from: data)
        } catch {
            SystemAlert.error("Bot changeable packages decode error: \(error)")
            
            if let raw = String(data: data, encoding: .utf8) {
                Logger().info("Bot raw packages: \(raw)")
            }
        }
    }
    
    func rename(_ newName: String, serviceId: Int) async {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            SystemAlert.error("Enter a name")
            return
        }
        
        guard let accessToken = accessToken() else { return }
        
        await performAction {
            guard await botServiceRenameAPI(
                newName: trimmed,
                serviceId: serviceId,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) else { return }
            
            self.service?.name = trimmed
        }
    }
    
    func changeAutorenew(_ enabled: Bool, serviceId: Int) async {
        guard let accessToken = accessToken() else { return }
        
        await performAction {
            guard await botServiceAutorenewAPI(
                enabled: enabled,
                serviceId: serviceId,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) else { return }
            
            self.service?.autorenew = enabled
            SystemAlert.done(enabled ? "Auto-renew enabled" : "Auto-renew disabled")
        }
    }
    
    func renew(months: Int, serviceId: Int) async -> ServiceRenewalResponse? {
        guard [1, 3, 6, 12].contains(months) else {
            SystemAlert.error("Unsupported period")
            return nil
        }
        
        guard let accessToken = accessToken() else { return nil }
        
        return await withCheckedContinuation { continuation in
            Task {
                await self.performAction {
                    guard let data = await botServiceRenewAPI(
                        months: months,
                        serviceId: serviceId,
                        accessToken: accessToken,
                        onBillingError: SystemAlert.error
                    ) else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    do {
                        let response = try BigAssDecoder.decode(ServiceRenewalResponse.self, from: data)
                        self.service?.expiresAt = response.newExpiresAt
                        
                        SystemAlert.done("Renewed for \(months) mo")
                        continuation.resume(returning: response)
                    } catch {
                        SystemAlert.error("Bot renewal failed", subtitle: error.localizedDescription)
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
    
    func changePackage(to packageId: Int, serviceId: Int, onSuccess: @escaping () -> Void) async {
        guard let accessToken = accessToken() else { return }
        
        await performAction {
            guard await botServiceChangePackageAPI(
                packageId: packageId,
                serviceId: serviceId,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) else { return }
            
            onSuccess()
            
            Logger().info("Upgrade requested")
            await self.fetchDetails(serviceId)
        }
    }
    
    private func performAction(_ work: @escaping () async -> Void) async {
        guard !isPerformingAction else { return }
        
        isPerformingAction = true
        defer { isPerformingAction = false }
        
        await work()
    }
}
