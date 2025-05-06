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
                .primary()
            
            Text("Endpoint: \(endpoint)")
                .footnote()
                .secondary()
            
            let id = Text(database.id)
                .primary()
            
            Text("Identifier: \(id)")
                .footnote()
                .secondary()
        }
        .padding()
        .frame(width: 800)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
//        .frame(minWidth: 200, maxWidth: 800)
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
