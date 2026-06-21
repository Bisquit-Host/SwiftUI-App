import SwiftUI
import Calagopus

struct DatabaseTab: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let databaseLimit: Int
    
    init(_ server: ServerAttributes) {
        databaseLimit = server.featureLimits.databases
    }
    
    var body: some View {
        List {
            DatabaseList(databaseLimit)
        }
        .navigationTitle("Databases")
        .refreshableTask {
            await vm.fetchDatabases()
        }
    }
}

#Preview {
    NavigationStack {
        DatabaseTab(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(DatabaseVM(""))
}
