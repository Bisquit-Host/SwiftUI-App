import SwiftUI
import Calagopus

@Observable
final class ServerSettingsVM {
    private let id: String
    private var originalAutoStartBehavior: ServerSettingsAutoStartBehavior = .never
    private var originalAutoKillEnabled = false
    private var originalAutoKillSeconds = 300
    private var originalTimezone = ""
    private var autoKillSaveTask: Task<Void, Never>?

    init(_ id: String) {
        self.id = id
    }

    var alertRename = false
    var serverName = ""
    var serverDescription = ""
    var username = ""
    var autoStartBehavior: ServerSettingsAutoStartBehavior = .never
    var autoKillEnabled = false
    var autoKillSeconds = 300
    var timezone = ""
    var isLoadingCalagopusSettings = false
    var isSavingAutoStart = false
    var isSavingAutoKill = false
    var isSavingTimezone = false

    var hasAutoStartChanges: Bool {
        autoStartBehavior != originalAutoStartBehavior
    }

    var hasAutoKillChanges: Bool {
        autoKillEnabled != originalAutoKillEnabled || autoKillSeconds != originalAutoKillSeconds
    }

    var hasTimezoneChanges: Bool {
        timezone != originalTimezone
    }

    func serverRename() async {
        do {
            try await CalagopusNet.client().rename(server: id, name: serverName, description: serverDescription)
        } catch {
            SystemAlert.error(error)
        }
    }

    func accountDetails() async {
        do {
            username = try await CalagopusClientFactory.client().account().username
        } catch {
            SystemAlert.error(error)
        }
    }

    func fetchCalagopusSettings() async {
        isLoadingCalagopusSettings = true

        do {
            let server = try await CalagopusClientFactory.client().server(id: id)
            apply(server)
        } catch {
            SystemAlert.error(error)
        }

        isLoadingCalagopusSettings = false
    }

    func saveAutoStart() async {
        isSavingAutoStart = true

        do {
            let client = try CalagopusClientFactory.client()
            let endpoint = try CalagopusGeneratedOperations.putApiClientServersServerSettingsAutoStart.endpoint(
                pathValues: ["server": id],
                body: ServerSettingsAutoStartRequest(behavior: autoStartBehavior.calagopusValue)
            )
            _ = try await client.send(endpoint, as: EmptyCalagopusResponse.self)
            originalAutoStartBehavior = autoStartBehavior
            SystemAlert.done("Auto-Start updated")
        } catch {
            SystemAlert.error(error)
        }

        isSavingAutoStart = false
    }

    func saveAutoKill() async {
        isSavingAutoKill = true

        do {
            let client = try CalagopusClientFactory.client()
            let endpoint = try CalagopusGeneratedOperations.putApiClientServersServerSettingsAutoKill.endpoint(
                pathValues: ["server": id],
                body: ServerSettingsAutoKillRequest(enabled: autoKillEnabled, seconds: autoKillEnabled ? Int64(autoKillSeconds) : nil)
            )
            _ = try await client.send(endpoint, as: EmptyCalagopusResponse.self)
            originalAutoKillEnabled = autoKillEnabled
            originalAutoKillSeconds = autoKillSeconds
            SystemAlert.done("Auto-Kill updated")
        } catch {
            SystemAlert.error(error)
        }

        isSavingAutoKill = false
    }

    func scheduleAutoKillSave() {
        autoKillSaveTask?.cancel()

        guard hasAutoKillChanges, !isLoadingCalagopusSettings else {
            return
        }

        autoKillSaveTask = Task {
            try? await Task.sleep(for: .milliseconds(400))

            guard !Task.isCancelled else { return }

            await saveAutoKill()
        }
    }

    func saveTimezone() async {
        isSavingTimezone = true

        do {
            let client = try CalagopusClientFactory.client()
            let endpoint = try CalagopusGeneratedOperations.putApiClientServersServerSettingsTimezone.endpoint(
                pathValues: ["server": id],
                body: ServerSettingsTimezoneRequest(timezone: timezone.isEmpty ? nil : timezone)
            )
            _ = try await client.send(endpoint, as: EmptyCalagopusResponse.self)
            originalTimezone = timezone
            SystemAlert.done("Timezone updated")
        } catch {
            SystemAlert.error(error)
        }

        isSavingTimezone = false
    }

    private func apply(_ server: CalagopusServer) {
        let autoStartBehavior = ServerSettingsAutoStartBehavior(server.autoStartBehavior)
        let autoKillEnabled = server.autoKill.enabled
        let autoKillSeconds = min(max(Int(server.autoKill.seconds), 1), 3600)
        let timezone = server.timezone ?? ""

        originalAutoStartBehavior = autoStartBehavior
        originalAutoKillEnabled = autoKillEnabled
        originalAutoKillSeconds = autoKillSeconds
        originalTimezone = timezone

        self.autoStartBehavior = autoStartBehavior
        self.autoKillEnabled = autoKillEnabled
        self.autoKillSeconds = autoKillSeconds
        self.timezone = timezone
    }
}
