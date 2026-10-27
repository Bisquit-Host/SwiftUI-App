import ScrechKit
import Calagopus

struct BackupGroupsView: View {
    @Environment(BackupVM.self) private var vm
    @State private var creatingGroup = false
    @State private var editingGroup: CalagopusServerBackupGroup?
    @State private var deletingGroup: CalagopusServerBackupGroup?

    var body: some View {
        List {
            ForEach(vm.backupGroups) { group in
                Section {
                    LabeledContent(group.name) {
                        Text(group.totalBackups, format: .number)
                    }

                    if vm.can("backup-groups.update") {
                        Button("Edit name and retention", systemImage: "pencil") {
                            editingGroup = group
                        }

                        AsyncButton("Move up", systemImage: "arrow.up") {
                            await vm.reorderGroup(group.uuid, offset: -1)
                        }
                        .disabled(vm.backupGroups.first?.uuid == group.uuid)

                        AsyncButton("Move down", systemImage: "arrow.down") {
                            await vm.reorderGroup(group.uuid, offset: 1)
                        }
                        .disabled(vm.backupGroups.last?.uuid == group.uuid)
                    }

                    if vm.can("backup-groups.delete") {
                        Button("Delete group", systemImage: "trash", role: .destructive) {
                            deletingGroup = group
                        }
                    }
                }
            }

            if vm.groupLoadFailed {
                AsyncButton("Retry loading groups", systemImage: "arrow.clockwise") {
                    await vm.fetchBackupGroups()
                }
            } else if vm.backupGroups.isEmpty && !vm.isLoadingGroups {
                ContentUnavailableView("No backup groups", systemImage: "folder")
            }
        }
        .disabled(vm.isUpdatingGroups)
        .navigationTitle("Backup groups")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                DismissButton()
            }

            if vm.can("backup-groups.create") {
                ToolbarItem(placement: .primaryAction) {
                    Button("Create group", systemImage: "plus") {
                        creatingGroup = true
                    }
                }
            }
        }
        .refreshable { await vm.refresh() }
        .task { await vm.fetchBackupGroups() }
        .sheet(isPresented: $creatingGroup) {
            NavigationStack { BackupGroupEditorView() }
                .environment(vm)
        }
        .sheet(item: $editingGroup) { group in
            NavigationStack { BackupGroupEditorView(group: group) }
                .environment(vm)
        }
        .sheet(item: $deletingGroup) { group in
            NavigationStack { BackupGroupDeleteView(group: group) }
                .environment(vm)
        }
    }
}
