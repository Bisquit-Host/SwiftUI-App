import ScrechKit
import Calagopus

struct BackupGroupDeleteView: View {
    @Environment(BackupVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    @State private var confirmation = ""
    @State private var lockBackups = false
    let group: CalagopusServerBackupGroup

    var body: some View {
        Form {
            Section {
                Text("Deleting this group keeps its backups and moves them to No group")
                TextField("Enter the group name to confirm", text: $confirmation)
                    .autocorrectionDisabled()
            } header: {
                Text(group.name)
            }

            Section {
                Toggle("Lock backups", isOn: $lockBackups)
            } footer: {
                Text("Lock the backups to protect them from automatic retention after removing the group")
            }
        }
        .disabled(vm.isUpdatingGroups)
        .navigationTitle("Delete group")
        .interactiveDismissDisabled(vm.isUpdatingGroups)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .disabled(vm.isUpdatingGroups)
            }

            ToolbarItem(placement: .confirmationAction) {
                AsyncButton("Delete", role: .destructive) {
                    if await vm.deleteGroup(group.uuid, lockBackups: lockBackups) {
                        dismiss()
                    }
                }
                .disabled(confirmation != group.name || vm.isUpdatingGroups)
            }
        }
    }
}
