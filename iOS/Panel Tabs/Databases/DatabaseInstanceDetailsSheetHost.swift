import ScrechKit
import Calagopus

/// Presented from the tab rather than the row, so list reloads can't dismiss it
struct DatabaseInstanceDetailsSheetHost: View {
    @Environment(DatabaseInstanceVM.self) private var vm
    
    private let instance: CalagopusDatabaseInstance
    
    init(_ instance: CalagopusDatabaseInstance) {
        self.instance = instance
    }
    
    var body: some View {
        NavigationStack {
            DatabaseInstanceDetailsSheet(vm.serverID, instance)
        }
    }
}
