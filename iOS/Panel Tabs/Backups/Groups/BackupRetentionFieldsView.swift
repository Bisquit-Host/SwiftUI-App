import SwiftUI
import Calagopus

struct BackupRetentionFieldsView: View {
    @Binding var retention: CalagopusBackupRetention

    var body: some View {
        Section {
            LabeledContent("Latest backups") {
                TextField("Count", value: $retention.count, format: .number.grouping(.never))
                    .multilineTextAlignment(.trailing)
            }

            LabeledContent("Days") {
                TextField("Days", value: $retention.days, format: .number.grouping(.never))
                    .multilineTextAlignment(.trailing)
            }

            LabeledContent("Daily backups") {
                TextField("Daily", value: $retention.daily, format: .number.grouping(.never))
                    .multilineTextAlignment(.trailing)
            }

            LabeledContent("Weekly backups") {
                TextField("Weekly", value: $retention.weekly, format: .number.grouping(.never))
                    .multilineTextAlignment(.trailing)
            }

            LabeledContent("Monthly backups") {
                TextField("Monthly", value: $retention.monthly, format: .number.grouping(.never))
                    .multilineTextAlignment(.trailing)
            }

            LabeledContent("Yearly backups") {
                TextField("Yearly", value: $retention.yearly, format: .number.grouping(.never))
                    .multilineTextAlignment(.trailing)
            }
        } header: {
            Text("Retention")
        } footer: {
            if !retention.isValid {
                Text("Enter whole numbers between 0 and 2147483647")
            } else if retention.isDisabled {
                Text("Automatic retention is disabled for this group")
            } else {
                Text("A backup is kept when any retention rule protects it — use 0 to disable a rule")
            }
        }
    }
}
