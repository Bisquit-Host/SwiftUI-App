import ScrechKit
import Calagopus

struct DatabaseDetailsSheet: View {
    private let database: CalagopusServerDatabase
    
    init(_ database: CalagopusServerDatabase) {
        self.database = database
    }
    
    var body: some View {
        List {
            DatabaseDetailsRow("Name", value: database.name)
            DatabaseDetailsRow("Host", value: database.host)
            DatabaseDetailsRow("Port", value: String(database.port))
            DatabaseDetailsRow("User", value: database.username)
            DatabaseDetailsRow("Password", value: database.password, privacySensitive: true)
#if !os(tvOS)
            Section {
                Button("Copy all", action: copyAll)
            }
#endif
        }
        .navigationTitle("Details")
        .toolbarTitleDisplayMode(.inline)
    }
    
#if !os(tvOS)
    private func copyAll() {
        let credentials = [
            ("Name", database.name),
            ("Host", database.host),
            ("Port", String(database.port)),
            ("User", database.username),
            ("Password", database.password ?? "Unavailable")
        ]
            .map { key, value in
                "\(key): \(value)"
            }
            .joined(separator: "\n")
        
        Pasteboard.copy(credentials)
        SystemAlert.copied()
    }
#endif
}

#Preview {
    NavigationStack {
        DatabaseDetailsSheet(PreviewProp.databaseAttributes)
    }
    .darkSchemePreferred()
}
