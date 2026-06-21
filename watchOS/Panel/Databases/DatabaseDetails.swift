import SwiftUI
import Calagopus

struct DatabaseDetails: View {
    private let database: DatabaseAttributes
    
    init(_ database: DatabaseAttributes) {
        self.database = database
    }
    
    var body: some View {
        List {
            DatabaseDetailsRow("Name", value: database.name)
            DatabaseDetailsRow("Host", value: database.host.address)
            DatabaseDetailsRow("Port", value: String(database.host.port))
            DatabaseDetailsRow("User", value: database.username)
            DatabaseDetailsRow("Password", value: database.password, privacySensitive: true)
            DatabaseDetailsRow("Connections from", value: database.connectionsFrom ?? "%")
        }
        .navigationTitle("Details")
    }
}

#Preview {
    NavigationStack {
        DatabaseDetails(PreviewProp.databaseAttributes)
    }
    .darkSchemePreferred()
}
