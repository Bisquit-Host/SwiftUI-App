import SwiftUI

struct StatRowDatabases: View {
    @State private var vm: DatabaseVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        vm = DatabaseVM(id)
    }
    
    @State private var sheetDatabases = false
    
    var body: some View {
        Button {
            sheetDatabases = true
        } label: {
            StatTile("Databases", value: vm.databases.count, icon: "tray")
        }
        .sheet($sheetDatabases) {
            DatabaseList(id)
                .environment(vm)
        }
        .task {
            await vm.fetchDatabases()
        }
    }
}

#Preview {
    StatRowDatabases("")
}
