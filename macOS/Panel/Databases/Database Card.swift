import ScrechKit
import PteroNet

struct DatabaseCard: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let database: DatabaseAttributes
    
    init(_ database: DatabaseAttributes) {
        self.database = database
    }
    
    var body: some View {
        let host = database.host
        
        VStack(alignment: .leading) {
            Text(database.name)
            
            let endpoint = Text(host.address + ":\(host.port)")
                .foregroundStyle(.primary)
            
            Text("Endpoint: \(endpoint)")
                .footnote()
                .secondary()
            
            let id = Text(database.id)
                .foregroundStyle(.primary)
            
            Text("Identifier: \(id)")
                .footnote()
                .secondary()
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .contextMenu {
            MenuButton("Rotate password", icon: "lock.open.rotation") {
                vm.rotatePassword(database.id)
            }
        }
    }
}

#Preview {
    DatabaseCard(sampleJSON(.databaseAttributes))
}
