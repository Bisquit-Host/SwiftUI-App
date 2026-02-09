import ScrechKit
import PteroNet

struct DatabaseDetailsSheet: View {
    private let database: DatabaseAttributes
    
    init(_ database: DatabaseAttributes) {
        self.database = database
    }
    
    var body: some View {
        List {
            Section {
                DatabaseDetailsRow("Name", value: database.name)
                DatabaseDetailsRow("Host", value: database.host.address)
                DatabaseDetailsRow("Port", value: String(database.host.port))
                DatabaseDetailsRow("User", value: database.username)
                DatabaseDetailsRow("Password", value: database.password, privacySensitive: true)
                DatabaseDetailsRow("Connections from", value: database.connectionsFrom ?? "%")
            }
        }
        .navigationTitle("Details")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Copy all", action: copyAll)
            }
        }
    }
    
    private func copyAll() {
        let credentials = [
            ("Name", database.name),
            ("Host", database.host.address),
            ("Port", String(database.host.port)),
            ("User", database.username),
            ("Password", database.password ?? "Unavailable"),
            ("Connections from", database.connectionsFrom ?? "%")
        ]
            .map { key, value in
                "\(key): \(value)"
            }
            .joined(separator: "\n")
        
        Pasteboard.copy(credentials)
        SystemAlert.copied()
    }
}

#Preview {
    NavigationStack {
        DatabaseDetailsSheet(PreviewProp.databaseAttributes)
    }
    .darkSchemePreferred()
}
