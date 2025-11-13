import SwiftUI
import PteroNet

struct DatabaseContextMenu: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let db: DatabaseAttributes
    
    init(_ db: DatabaseAttributes) {
        self.db = db
    }
    
    var body: some View {
        Button("Rotate password", systemImage: "lock.open.rotation") {
            Task {
                await vm.rotatePassword(db.id)
            }
        }
        
        Divider()
        
        Button("Delete", systemImage: "trash", role: .destructive) {
            Task {
                await vm.deleteDatabase(db.id)
            }
        }
    }
}
