import SwiftUI
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
                .listRowBackground(Color.gray.opacity(0.2))
        }
        .scrollIndicators(.never)
        .overlay {
            if databaseLimit == 0 {
                ContentUnavailableView(
                    "Databases are unavailable",
                    systemImage: "externaldrive.badge.xmark"
                )
            } else if vm.databases.isEmpty {
                ContentUnavailableView(
                    "No databases found",
                    systemImage: "externaldrive.badge.icloud"
                )
            }
        }
#if !os(tvOS)
        .frame(maxWidth: 500)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
#endif
        .refreshableTask {
            await vm.fetchDatabases()
        }
        .toolbar {
            Button("Create Database", systemImage: "externaldrive.badge.plus") {
                vm.alertCreate = true
            }
            .labelStyle(.iconOnly)
            .disabled(vm.databases.count >= databaseLimit)
        }
        .alert("Create Database", isPresented: $vm.alertCreate) {
            TextField("Example", text: $vm.newDatabaseName)
                .autocorrectionDisabled()
                .limitInputLength($vm.newDatabaseName, length: 31)
            
            Button("Create", role: .confirm) {
                createDatabase()
            }
            
            Button("Cancel", role: .cancel) {
                vm.newDatabaseName = ""
            }
        }
    }
    
    private func createDatabase() {
        Task {
            await vm.createDatabase()
        }
    }
}

#Preview {
    DatabaseTab(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(DatabaseVM(""))
}
