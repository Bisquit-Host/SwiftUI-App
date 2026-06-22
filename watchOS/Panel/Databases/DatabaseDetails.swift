import SwiftUI
import Calagopus

struct DatabaseDetails: View {
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
