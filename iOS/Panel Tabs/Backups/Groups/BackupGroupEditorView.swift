import ScrechKit
import Calagopus

struct BackupGroupEditorView: View {
    @Environment(BackupVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    @State private var draft: BackupGroupDraft
    private let groupID: String?

    init(group: CalagopusServerBackupGroup? = nil) {
        groupID = group?.uuid
        _draft = State(initialValue: BackupGroupDraft(group: group))
    }

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $draft.name)
                    .autocorrectionDisabled()
            }

            BackupRetentionFieldsView(retention: $draft.retention)
        }
        .disabled(vm.isUpdatingGroups)
        .navigationTitle(groupID == nil ? "Create group" : "Edit group")
        .interactiveDismissDisabled(vm.isUpdatingGroups)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .disabled(vm.isUpdatingGroups)
            }

            ToolbarItem(placement: .confirmationAction) {
                AsyncButton("Save") {
                    if await vm.saveGroup(groupID, name: draft.trimmedName, retention: draft.retention) {
                        dismiss()
                    }
                }
                .disabled(!draft.isValid || vm.isUpdatingGroups)
            }
        }
    }
}
