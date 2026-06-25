import Calagopus

extension CalagopusScheduleTriggerType {
    var scheduleLabel: String {
        switch self {
        case .cron: "Cron"
        case .powerAction: "Power action"
        case .serverState: "Server state"
        case .backupStatus: "Backup status"
        case .consoleLine: "Console line"
        case .crash: "Crash"
        }
    }
}
