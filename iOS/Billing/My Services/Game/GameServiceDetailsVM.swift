import Foundation
import BisquitoNet
import PteroNet
import OSLog

@Observable
final class GameServiceDetailsVM {
    var service: BillingServiceDetails?
    var changeablePackages: [ChangeablePackage] = []
    var isLoading = false
    var isPerformingAction = false
    var topupAlertContext: TopupAlertContext?
    
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
        
        service = await gameServiceDetailsAPI(
            serviceId: serviceId,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        )
    }
    
    func fetchChangeablePackages(_ serviceId: Int) async {
        guard let accessToken = accessToken() else { return }
        
        changeablePackages = await gameServiceChangeablePackagesAPI(
            serviceId: serviceId,
            accessToken: accessToken,
            emptyResponse: [],
            onBillingError: SystemAlert.error
        ) ?? []
    }
    
    func rename(_ newName: String, serviceId: Int) async {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            SystemAlert.error("Enter a name")
            return
        }
        
        guard let accessToken = accessToken() else { return }
        
        await performAction {
            guard await gameServiceRenameAPI(
                newName: trimmed,
                serviceId: serviceId,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) != nil else { return }
            
            self.service?.name = trimmed
        }
    }
    
    func changeAutorenew(_ enabled: Bool, serviceId: Int) async {
        guard let accessToken = accessToken() else { return }
        
        await performAction {
            guard await gameServiceAutorenewAPI(
                enabled: enabled,
                serviceId: serviceId,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) != nil else { return }
            
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
                    guard let response: ServiceRenewalResponse = await gameServiceRenewAPI(
                        months: months,
                        serviceId: serviceId,
                        accessToken: accessToken,
                        onBillingError: { @MainActor title, subtitle in
                            self.handleBillingError(title, subtitle: subtitle ?? "", context: .serviceBilling)
                        }
                    ) else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    self.service?.expiresAt = response.newExpiresAt
                    
                    SystemAlert.done("Renewed for \(months) mo")
                    continuation.resume(returning: response)
                }
            }
        }
    }
    
    func changePackage(to packageId: Int, serviceId: Int, onSuccess: @escaping () -> Void) async {
        guard let accessToken = accessToken() else { return }
        
        await performAction {
            guard await gameServiceChangePackageAPI(
                packageId: packageId,
                serviceId: serviceId,
                accessToken: accessToken,
                onBillingError: { @MainActor title, subtitle in
                    self.handleBillingError(title, subtitle: subtitle ?? "", context: .upgrade)
                }
            ) != nil else { return }
            
            onSuccess()
            
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
    
    @MainActor
    private func handleBillingError(_ title: String, subtitle: String, context: TopupAlertContext) {
        if isInsufficientFundsError(title, subtitle: subtitle) {
            topupAlertContext = context
            return
        }
        
        SystemAlert.error(title, subtitle: subtitle)
    }
}
