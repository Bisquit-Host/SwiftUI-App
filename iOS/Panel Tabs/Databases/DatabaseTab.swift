import ScrechKit
import Calagopus

struct DatabaseTab: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let databaseLimit: Int
    
    init(_ server: CalagopusServer) {
        databaseLimit = server.featureLimits.databases
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            DatabaseList()
        }
        .panelContentMargins()
        .scrollIndicators(.never)
        .overlay {
            if databaseLimit == 0 {
                ContentUnavailableView("Databases are unavailable", systemImage: "externaldrive.badge.xmark")
            } else if vm.isLoadingDatabases && vm.databases.isEmpty {
                ProgressView()
            } else if vm.hasFinishedLoadingDatabases && vm.databases.isEmpty {
                ContentUnavailableView("No databases found", systemImage: "externaldrive.badge.icloud")
            }
        }
        .refreshableTask {
            await vm.fetchDatabases()
        }
        .toolbar {
            PanelToolbarItem {
                Button("Create Database", systemImage: "externaldrive.badge.plus") {
                    vm.alertCreate = true
                }
                .labelStyle(.iconOnly)
                .disabled(vm.databases.count >= databaseLimit)
            }
        }
        .alert("Create Database", isPresented: $vm.alertCreate) {
            TextField("Example", text: $vm.newDatabaseName)
                .autocorrectionDisabled()
                .limitInputLength($vm.newDatabaseName, length: 31)
            
            AsyncButton("Create", role: .confirm, action: vm.createDatabase)
            
            Button("Cancel", role: .cancel) {
                vm.newDatabaseName = ""
            }
        }
    }
}

#Preview {
    DatabaseTab(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(DatabaseVM(""))
}
