import ScrechKit
import Calagopus

struct DatabaseInstanceDetailsSheet: View {
    @Environment(DatabaseInstanceVM.self) private var listVM
    @Environment(\.dismiss) private var dismiss
    @State private var vm: DatabaseInstanceDetailsVM
    
    init(_ serverID: String, _ instance: CalagopusDatabaseInstance) {
        vm = DatabaseInstanceDetailsVM(serverID, instance: instance)
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            DatabaseInstanceStatusSection()
            
            DatabaseInstanceStatsSection()
            
            if vm.instance.type != .redis {
                DatabaseInstanceDatabasesSection()
            }
            
            DatabaseInstanceUsersSection()
            
            Section {
                NavigationLink {
                    DatabaseInstanceLogsView()
                        .environment(vm)
                } label: {
                    Label("Logs", systemImage: "text.alignleft")
                }
            }
        }
        .navigationTitle(vm.instance.name)
        .toolbarTitleDisplayMode(.inline)
        .animation(.default, value: vm.databases)
        .animation(.default, value: vm.users)
        .refreshableTask {
            await vm.fetchAll()
        }
        .task {
            await vm.pollResources()
        }
        .onChange(of: vm.instance) {
            listVM.replace(vm.instance)
        }
        .alert("Rename", isPresented: $vm.alertRename) {
            TextField(vm.instance.name, text: $vm.newName)
                .autocorrectionDisabled()
                .limitInputLength($vm.newName, length: 31)
            
            AsyncButton("Save", role: .confirm, action: vm.rename)
                .disabled(vm.newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            Button("Cancel", role: .cancel) {
                vm.newName = ""
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark", role: .close) {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                DatabaseInstanceDetailsMenu()
            }
        }
        .environment(vm)
    }
}

#Preview {
    NavigationStack {
        DatabaseInstanceDetailsSheet("", PreviewProp.databaseInstance)
    }
    .darkSchemePreferred()
    .environment(DatabaseInstanceVM(""))
}
