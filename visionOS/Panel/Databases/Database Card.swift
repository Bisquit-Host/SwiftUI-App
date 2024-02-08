import SwiftUI
import PteroNet

struct DatabaseCard: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let database: DatabaseAttributes
    
    init(_ database: DatabaseAttributes) {
        self.database = database
    }
    
    var body: some View {
        HStack {
            Text(database.name)
        }
    }
}

//#Preview {
//    DatabaseCard()
//}
