import SwiftUI
import Calagopus

struct DatabaseCard: View {
    private let database: CalagopusServerDatabase
    
    init(_ database: CalagopusServerDatabase) {
        self.database = database
    }
    
    var body: some View {
        NavigationLink {
            DatabaseDetails(database)
        } label: {
            HStack {
                Image(systemName: "tray.2")
                
                Text(database.name)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    List {
        DatabaseCard(PreviewProp.databaseAttributes)
    }
    .darkSchemePreferred()
}
