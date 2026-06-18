import SwiftUI

struct DatabaseList: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let databaseLimit: Int
    
    init(_ databaseLimit: Int) {
        self.databaseLimit = databaseLimit
    }
    
    var body: some View {
        if databaseLimit == 0 {
            ContentUnavailableView(
                "Databases are unavailable",
                systemImage: "externaldrive.badge.xmark"
            )
        } else if vm.databases.isEmpty {
            ContentUnavailableView(
                "No databases found",
                systemImage: "externaldrive.badge.icloud"
            )
        } else {
            Section {
                ForEach(vm.databases) {
                    DatabaseCard($0)
                }
            } header: {
                Text("\(vm.databases.count)/\(databaseLimit)")
            }
        }
    }
}

#Preview {
    List {
        DatabaseList(4)
    }
    .darkSchemePreferred()
    .environment(DatabaseVM(""))
}
