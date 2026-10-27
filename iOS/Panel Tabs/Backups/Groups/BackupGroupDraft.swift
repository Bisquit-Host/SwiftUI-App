import Foundation
import Calagopus

struct BackupGroupDraft {
    var name = ""
    var retention = CalagopusBackupRetention()

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isValid: Bool {
        !trimmedName.isEmpty && trimmedName.count <= 255 && retention.isValid
    }

    init(group: CalagopusServerBackupGroup? = nil) {
        if let group {
            name = group.name
            retention = group.retention
        }
    }
}
