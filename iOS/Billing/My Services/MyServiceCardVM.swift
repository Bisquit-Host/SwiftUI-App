import SwiftUI
import BisquitoNet

@Observable
final class MyServiceCardVM {
    var newName = ""
    private(set) var isRenaming = false

    func prepareRename(for service: BillingMyService) {
        newName = service.name
    }

    func rename(service: BillingMyService) async {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            SystemAlert.error("Enter a name")
            return
        }

        guard
            trimmed != service.name,
            !isRenaming,
            let accessToken = accessToken()
        else {
            return
        }

        isRenaming = true
        defer {
            isRenaming = false
            newName = ""
        }

        let didRename: Bool = switch service {
        case .cloud:
            await cloudServiceRenameAPI(
                newName: trimmed,
                serviceId: service.id,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) != nil

        case .game:
            await gameServiceRenameAPI(
                newName: trimmed,
                serviceId: service.id,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) != nil

        case .bot:
            await botServiceRenameAPI(
                newName: trimmed,
                serviceId: service.id,
                accessToken: accessToken,
                onBillingError: SystemAlert.error
            ) != nil
        }

        guard didRename else { return }

        SystemAlert.copied("Name updated")
        NotificationCenter.default.post(name: .billingMyServicesShouldRefresh, object: nil)
    }
}
