import ScrechKit
import PteroNet

struct DatabaseCard: View {
    @Environment(DatabaseVM.self) private var vm
#if os(iOS)
    @Environment(BiometryVM.self) private var biometry
    @EnvironmentObject private var store: ValueStore
#endif
    private let db: DatabaseAttributes
    
    init(_ db: DatabaseAttributes) {
        self.db = db
    }
    
    @State private var alertDelete = false
    @State private var showDetails = false
    
    var body: some View {
        Button {
            showDetails = true
        } label: {
            HStack {
                Image(systemName: "tray.2")
                    .title2(.semibold)
                    .frame(width: 32)
                
                VStack(alignment: .leading) {
                    Text(db.name)
                        .headline()
                }
                .minimumScaleFactor(0.25)
                .lineLimit(1)
                
                Spacer()
            }
            .foregroundStyle(.foreground)
        }
#if !os(tvOS)
        .swipeActions {
            SFButton("trash") {
                alertDelete = true
            }
            .tint(.red)
        }
#endif
        .contextMenu {
            Button("Details", systemImage: "info.circle") {
                showDetails = true
            }

            Button("Rotate password", systemImage: "lock.open.rotation") {
                Task {
                    await vm.rotatePassword(db.id)
                }
            }
            
            Divider()
            
            Button("Delete", systemImage: "trash", role: .destructive) {
                alertDelete = true
            }
        }
        .alert("Detele Database", isPresented: $alertDelete) {
            Button("Delete", role: .destructive, action: delete)
        } message: {
            Text("Are you sure you want to delete \"\(db.name)\"? This database will be deleted immediately. You can't undo this action")
        }
        .sheet(isPresented: $showDetails) {
            NavigationStack {
                DatabaseDetailsSheet(db)
            }
        }
    }
    
    private func delete() {
        Task {
#if os(iOS)
            if store.useBiometry, await !biometry.authenticate() {
                SystemAlert.error("Biometry authentication failed")
                return
            }
#endif
            await vm.deleteDatabase(db.id)
        }
    }
}

#Preview {
    List {
        DatabaseCard(PreviewProp.databaseAttributes)
    }
    .darkSchemePreferred()
    .environment(DatabaseVM(""))
}
