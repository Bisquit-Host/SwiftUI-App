import ScrechKit

struct DatabaseInstanceDetailsMenu: View {
    @Environment(DatabaseInstanceDetailsVM.self) private var vm
    @Environment(DatabaseInstanceVM.self) private var listVM
    @Environment(\.dismiss) private var dismiss
#if os(iOS)
    @Environment(BiometryVM.self) private var biometry
    @EnvironmentObject private var store: ValueStore
#endif
    
    @State private var alertDelete = false
    @State private var export: DatabaseInstanceExport?
    
    var body: some View {
        Menu("Actions", systemImage: "ellipsis") {
            Button("Rename", systemImage: "pencil") {
                vm.newName = vm.instance.name
                vm.alertRename = true
            }
            
            AsyncButton(
                vm.instance.isLocked ? "Unlock" : "Lock",
                systemImage: vm.instance.isLocked ? "lock.open" : "lock",
                action: vm.toggleLock
            )
            
            if vm.instance.type == .redis {
                AsyncButton("Export", systemImage: "square.and.arrow.up") {
                    if let dump = await vm.export() {
                        export = DatabaseInstanceExport(name: vm.instance.name, contents: dump)
                    }
                }
                .disabled(vm.isOffline)
            }
            
            if !vm.instance.isLocked {
                Divider()
                
                Button("Delete", systemImage: "trash", role: .destructive) {
                    alertDelete = true
                }
            }
        }
        .alert("Delete Managed Database", isPresented: $alertDelete) {
            AsyncButton("Delete", role: .destructive, action: delete)
        } message: {
            Text("Are you sure you want to delete \"\(vm.instance.name)\"? All of its databases and users will be deleted immediately. You can't undo this action")
        }
        .sheet(item: $export) {
            DatabaseInstanceExportSheet($0)
        }
    }
    
    private func delete() async {
#if os(iOS)
        if store.useBiometry, await !biometry.authenticate() {
            SystemAlert.error("Biometry authentication failed")
            return
        }
#endif
        if await listVM.deleteInstance(vm.instance.id) {
            dismiss()
        }
    }
}
