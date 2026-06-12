import SwiftUI
import PteroNet

struct DatabaseCard: View {
    private let database: DatabaseAttributes
    
    init(_ database: DatabaseAttributes) {
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
