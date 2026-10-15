import ScrechKit

struct DatabaseInstanceCredentialsView: View {
    @Environment(DatabaseInstanceDetailsVM.self) private var vm
    
    private let userID: String
    
    init(_ userID: String) {
        self.userID = userID
    }
    
    @State private var databaseID: String?
    
    var body: some View {
        if let user = vm.user(userID) {
            let databaseName = vm.databaseName(user.databaseUuid ?? databaseID)
            let jdbc = vm.instance.jdbcConnectionString(username: user.username, password: user.password, database: databaseName)
            
            List {
                Section {
                    DatabaseDetailsRow("Address", value: vm.instance.address, privacySensitive: true)
                    DatabaseDetailsRow("User", value: user.username)
                    DatabaseDetailsRow("Password", value: user.password, privacySensitive: true)
                }
                
                if user.databaseUuid == nil, vm.databases.count > 1 {
                    Section {
                        Picker("Database", selection: $databaseID) {
                            ForEach(vm.databases) {
                                Text($0.name)
                                    .tag($0.id as String?)
                            }
                        }
                    } footer: {
                        Text("Used in the connection string")
                    }
                }
                
                if let jdbc {
                    Section {
                        DatabaseDetailsRow("JDBC connection string", value: jdbc, privacySensitive: true)
                    }
                }
                
                Section {
                    AsyncButton("Rotate password", systemImage: "lock.open.rotation") {
                        await vm.rotatePassword(user.id)
                    }
                    .disabled(vm.instance.isLocked || (vm.isOffline && vm.instance.type != .redis))
                }
            }
            .navigationTitle(user.username)
            .toolbarTitleDisplayMode(.inline)
            .onAppear {
                if databaseID == nil {
                    databaseID = vm.databases.first?.id
                }
            }
        } else {
            ContentUnavailableView("User not found", systemImage: "person.slash")
        }
    }
}

#Preview {
    NavigationStack {
        DatabaseInstanceCredentialsView("")
    }
    .darkSchemePreferred()
    .environment(DatabaseInstanceDetailsVM("", instance: PreviewProp.databaseInstance))
}
