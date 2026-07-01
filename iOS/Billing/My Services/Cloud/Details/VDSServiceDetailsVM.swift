import Foundation
import BisquitoNet
import Calagopus
import OSLog

@Observable
final class VDSServiceDetailsVM {
    var service: CloudServiceDetails?
    var history: [CloudServiceHistoryItem] = []
    var charts: CloudServiceCharts?
    var osOptions: [CloudServiceOSCategory] = []
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
            group.addTask { await self.fetchHistory(serviceId) }
            group.addTask { await self.fetchCharts(serviceId) }
            group.addTask { await self.fetchOSOptions(serviceId) }
            
            if service?.state != .suspended && service?.state != .deleted {
                group.addTask {
                    await self.fetchChangeablePackages(serviceId)
                }
            }
        }
    }
    
    func fetchDetails(_ serviceId: Int) async {
        guard let accessToken = accessToken() else { return }
        
        service = await cloudServiceDetailsAPI(
            serviceId: serviceId,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        )
    }
    
    func fetchChangeablePackages(_ serviceId: Int) async {
        guard let accessToken = accessToken() else { return }
        
        changeablePackages = await cloudServiceChangeablePackagesAPI(
            serviceId: serviceId,
            accessToken: accessToken,
            emptyResponse: [],
            onBillingError: SystemAlert.error
        ) ?? []
    }
    
    func fetchHistory(_ serviceId: Int) async {
        guard let accessToken = accessToken() else { return }
        
        history = await cloudServiceHistoryAPI(
            serviceId: serviceId,
            accessToken: accessToken,
            emptyResponse: [],
            onBillingError: SystemAlert.error
        ) ?? []
    }
    
    func fetchCharts(_ serviceId: Int) async {
        guard let accessToken = accessToken() else { return }
        
        charts = await cloudServiceChartsAPI(
            serviceId: serviceId,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        )
    }
    
    func fetchOSOptions(_ serviceId: Int) async {
        guard let accessToken = accessToken() else { return }
        
        osOptions = await cloudServiceOSOptionsAPI(
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
            guard await cloudServiceRenameAPI(
                newName: trimmed,
                serviceId: serviceId,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) != nil else { return }
            
            self.service?.name = trimmed
            SystemAlert.done("Name updated")
        }
    }
    
    func changePassword(_ password: String, for serviceId: Int) async {
        let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmed.count >= 8, trimmed.count <= 32 else {
            SystemAlert.error(String(localized: "Password must be 8-32 characters, \"\(password)\" doesn't fit"))
            return
        }
        
        guard let accessToken = accessToken() else { return }
        
        await performAction {
            guard await cloudServiceChangePasswordAPI(
                password: trimmed,
                serviceId: serviceId,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) != nil else { return }
            
            SystemAlert.done("Root password updated")
        }
    }
    
    func reinstall(osId: Int, serviceId: Int) async {
        guard let accessToken = accessToken() else { return }
        
        await performAction {
            guard await cloudServiceReinstallAPI(
                osId: osId,
                serviceId: serviceId,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) != nil else { return }
            
            Logger().info("Reinstall started")
        }
    }
    
    func changeAutorenew(_ enabled: Bool, serviceId: Int) async {
        guard let accessToken = accessToken() else { return }
        
        await performAction {
            guard await cloudServiceAutorenewAPI(
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
                    guard let response: ServiceRenewalResponse = await cloudServiceRenewAPI(
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
                    
                    SystemAlert.done(String(localized: "Renewed for \(months) mo"))
                    continuation.resume(returning: response)
                }
            }
        }
    }
    
    func changePackage(to packageId: Int, serviceId: Int, onSuccess: @escaping () -> Void) async {
        guard let accessToken = accessToken() else { return }
        
        await performAction {
            guard await cloudServiceChangePackageAPI(
                packageId: packageId,
                serviceId: serviceId,
                accessToken: accessToken,
                onBillingError: { @MainActor title, subtitle in
                    self.handleBillingError(title, subtitle: subtitle ?? "", context: .upgrade)
                }
            ) != nil else { return }
            
            onSuccess()
            
            Logger().info("Upgrade requested")
            await self.fetchDetails(serviceId)
        }
    }
    
    func power(_ action: String, serviceId: Int) async {
        guard ["start", "stop", "restart"].contains(action) else { return }
        guard let accessToken = accessToken() else { return }
        
        await performAction {
            guard await cloudServicePowerAPI(
                action: action,
                serviceId: serviceId,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) != nil else {
                Logger().error("Power action \(action) failed")
                return
            }
            
            Logger().info("Action sent: \(action.capitalized)")
        }
    }
    
    // MARK: - Networking
    private func performAction(_ work: @escaping () async -> Void) async {
        guard !isPerformingAction else { return }
        
        isPerformingAction = true
        defer { isPerformingAction = false }
        
        await work()
    }
    
    private func handleBillingError(_ title: String, subtitle: String, context: TopupAlertContext) {
        if isInsufficientFundsError(title, subtitle: subtitle) {
            topupAlertContext = context
            return
        }
        
        SystemAlert.error(title, subtitle: subtitle)
    }
}
