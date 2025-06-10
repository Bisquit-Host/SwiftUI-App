import ScrechKit
import PteroNet

struct DatabaseCard: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let db: DatabaseAttributes
    
    init(_ db: DatabaseAttributes) {
        self.db = db
    }
    
    @State private var alertDelete = false
    
    var body: some View {
        let host = db.host
        
        Button {
            
        } label: {
            HStack {
                Image(systemName: "tray.2")
                    .title2(.semibold)
                    .frame(width: 32)
                
                VStack(alignment: .leading) {
                    Text(db.name)
                        .headline()
                    
                    let endpoint = Text(host.address + ":\(host.port)")
                        .foregroundStyle(.primary)
                    
                    Text("Endpoint: \(endpoint)")
                        .footnote()
                        .secondary()
                    
                    let id = Text(db.id)
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
#if !os(tvOS)
            if let password = db.password {
                Button("Copy password") {
                    UIPasteboard.general.string = password
                }
            }
#endif
            MenuButton("Rotate password", icon: "lock.open.rotation") {
                Task {
                    await vm.rotatePassword(db.id)
                }
            }
            
            Section {
                MenuButton("Delete", role: .destructive, icon: "trash") {
                    alertDelete = true
                }
            }
        }
        .alert("Detele Database", isPresented: $alertDelete) {
            Button("Delete", role: .destructive) {
                Task {
                    await vm.deleteDatabase(db.id)
                }
            }
        } message: {
            Text("Are you sure you want to delete \"\(db.name)\"? This database will be deleted immediately. You can't undo this action")
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
