import ScrechKit
import PteroNet

struct DatabaseContextMenu: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let db: DatabaseAttributes
    
    init(_ db: DatabaseAttributes) {
        self.db = db
    }
    
    var body: some View {
        MenuButton("Rotate password", icon: "lock.open.rotation") {
            vm.rotatePassword(db.id)
        }
        
        Section {
            MenuButton("Delete", role: .destructive, icon: "trash") {
                vm.deleteDatabase(db.id)
            }
        }
    }
}
