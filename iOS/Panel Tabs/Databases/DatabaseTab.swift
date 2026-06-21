import SwiftUI
import Calagopus

struct DatabaseTab: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let databaseLimit: Int
    
    init(_ server: ServerAttributes) {
        databaseLimit = server.featureLimits.databases
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            DatabaseList(databaseLimit)
                .listRowBackground(Color.gray.opacity(0.2))
        }
        .scrollIndicators(.never)
#if !os(tvOS)
        .frame(maxWidth: 500)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
#endif
        .refreshableTask {
            await vm.fetchDatabases()
        }
        .alert("Create Database", isPresented: $vm.alertCreate) {
            TextField("", text: $vm.newDatabaseName)
                .autocorrectionDisabled()
                .limitInputLength($vm.newDatabaseName, length: 48)
            
            Button("Create", role: .confirmy) {
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
