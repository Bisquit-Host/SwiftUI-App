import SwiftUI

struct DatabaseList: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let databaseLimit: Int
    
    init(_ databaseLimit: Int = 0) {
        self.databaseLimit = databaseLimit
    }
    
    var body: some View {
        List {
            ForEach(vm.databases, id: \.id) { db in
                DatabaseCard(db)
            }
        }
        .refreshableTask {
            vm.fetchDatabases()
        }
    }
}

#Preview {
    DatabaseList()
}
