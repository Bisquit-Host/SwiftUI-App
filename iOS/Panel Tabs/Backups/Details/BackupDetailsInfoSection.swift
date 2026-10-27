import ScrechKit
import Calagopus

struct BackupDetailsInfoSection: View {
    @Environment(BackupVM.self) private var vm

    private let backup: CalagopusServerBackup
    private let isSystem: Bool

    init(_ backup: CalagopusServerBackup, isSystem: Bool) {
        self.backup = backup
        self.isSystem = isSystem
    }

    var body: some View {
        Section {
            LabeledContent("Kind", value: vm.kindName(for: backup))

            if isSystem {
                LabeledContent("Source") {
                    Text("System")
                }
            } else if let group = vm.backupGroup(backup.backupGroupUuid) {
                LabeledContent("Backup group", value: group.name)
            }

            LabeledContent("Size", value: formatBytes(backup.bytes))

            LabeledContent("Files") {
                Text(backup.files, format: .number)
            }

            LabeledContent("Created") {
                Text(backup.created, format: .dateTime)
            }

            if let completed = backup.completed {
                LabeledContent("Completed") {
                    Text(completed, format: .dateTime)
                }

                LabeledContent("Duration") {
                    Text(Duration.seconds(completed.timeIntervalSince(backup.created)), format: .units(allowed: [.hours, .minutes, .seconds], width: .abbreviated))
                }
            }
        }

        if let checksum = backup.checksum {
            Section {
                BackupDetailsCopyRow("Checksum", value: checksum)
            }
        }

        Section {
            LabeledContent("Locked") {
                Text(backup.isLocked ? "Yes" : "No")
            }
            
            LabeledContent("Browsable") {
                Text(backup.isBrowsable ? "Yes" : "No")
            }
            
            LabeledContent("Streaming") {
                Text(backup.isStreaming ? "Yes" : "No")
            }
        }
    }
}

#Preview {
    List {
        BackupDetailsInfoSection(PreviewProp.backupAttributes, isSystem: false)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
