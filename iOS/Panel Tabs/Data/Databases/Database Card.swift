import ScrechKit
import PteroNet

struct DatabaseCard: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let database: DatabaseAttributes
    
    init(_ database: DatabaseAttributes) {
        self.database = database
    }
    
    @State private var alertDelete = false
    
    var body: some View {
        let host = database.host
        
        Button {
            
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "tray.2")
                    .title2()
                
                VStack(alignment: .leading) {
                    Text(database.name)
                        .headline()
                    
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
                .minimumScaleFactor(0.25)
                .lineLimit(1)
            }
            .foregroundStyle(.foreground)
        }
#if !os(tvOS)
        .swipeActions {
            Button {
                alertDelete = true
            } label: {
                Image(systemName: "trash")
                    .tint(.red)
            }
        }
#endif
        .contextMenu {
            MenuButton("Rotate password", icon: "lock.open.rotation") {
                vm.rotatePassword(database.id)
            }
            
            Section {
                MenuButton("Delete", role: .destructive, icon: "trash") {
                    alertDelete = true
                }
            }
        }
        .alert("Detele Database", isPresented: $alertDelete) {
            Button("Delete", role: .destructive) {
                vm.deleteDatabase(database.id)
            }
        } message: {
            Text("Are you sure you want to delete \"\(database.name)\"? This database will be deleted immediately. You can't undo this action")
        }
    }
}

#Preview {
    List {
        DatabaseCard(
            sampleJSON(.databaseAttributes)
        )
    }
}
