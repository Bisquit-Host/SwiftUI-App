import SwiftUI
import Calagopus

struct DatabaseDetails: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let instance: CalagopusDatabaseInstance
    
    init(_ instance: CalagopusDatabaseInstance) {
        self.instance = instance
    }
    
    @State private var users: [CalagopusDatabaseInstanceUser] = []
    
    var body: some View {
        List {
            Section {
                DatabaseDetailsRow("Type", value: instance.type.label)
                DatabaseDetailsRow("Address", value: instance.address, privacySensitive: true)
            }
            
            ForEach(users) { user in
                Section {
                    DatabaseDetailsRow("User", value: user.username)
                    DatabaseDetailsRow("Password", value: user.password, privacySensitive: true)
                }
            }
        }
        .navigationTitle(instance.name)
        .task {
            users = await vm.users(instance.id)
        }
    }
}

#Preview {
    NavigationStack {
        DatabaseDetails(PreviewProp.databaseInstance)
    }
    .darkSchemePreferred()
    .environment(DatabaseVM(""))
}
