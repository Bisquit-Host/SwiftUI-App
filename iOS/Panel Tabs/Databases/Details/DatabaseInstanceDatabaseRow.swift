import ScrechKit
import Calagopus

struct DatabaseInstanceDatabaseRow: View {
    @Environment(DatabaseInstanceDetailsVM.self) private var vm
    
    private let database: CalagopusDatabaseInstanceDatabase
    
    init(_ database: CalagopusDatabaseInstanceDatabase) {
        self.database = database
    }
    
    @State private var alertDelete = false
    @State private var export: DatabaseInstanceExport?
    
    var body: some View {
        HStack {
            Label(database.name, systemImage: "tablecells")
            
            Spacer()
            
            if let size = vm.databaseSizes[database.id] {
                Text(formatBytes(size))
                    .footnote()
                    .secondary()
                    .monospacedDigit()
            }
        }
        .task {
            await vm.fetchSize(database.id)
        }
        .swipeActions {
            if !vm.instance.isLocked {
                Button("Delete", systemImage: "trash") {
                    alertDelete = true
                }
                .labelStyle(.iconOnly)
                .tint(.red)
            }
        }
        .contextMenu {
            Button("Copy name", systemImage: "doc.on.doc") {
                Pasteboard.copy(database.name)
                SystemAlert.copied()
            }
            
            AsyncButton("Export", systemImage: "square.and.arrow.up") {
                if let dump = await vm.exportDatabase(database.id) {
                    export = DatabaseInstanceExport(name: database.name, contents: dump)
                }
            }
            .disabled(vm.isOffline)
            
            if !vm.instance.isLocked {
                Divider()
                
                Button("Delete", systemImage: "trash", role: .destructive) {
                    alertDelete = true
                }
            }
        }
        .alert("Delete Database", isPresented: $alertDelete) {
            AsyncButton("Delete", role: .destructive) {
                await vm.deleteDatabase(database.id)
            }
        } message: {
            Text("Are you sure you want to delete \"\(database.name)\"? You can't undo this action")
        }
        .sheet(item: $export) {
            DatabaseInstanceExportSheet($0)
        }
    }
}
