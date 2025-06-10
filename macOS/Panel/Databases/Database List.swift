import SwiftUI

struct DatabaseList: View {
    @State private var vm: DatabaseVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = DatabaseVM(id)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(vm.databases) { database in
                    DatabaseCard(database)
                }
            }
        }
        .environment(vm)
        .navigationTitle("Databases")
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .task {
            await vm.fetchDatabases()
        }
        .onChange(of: id) {
            Task {
                await vm.fetchDatabases()
            }
        }
        .overlay {
            if vm.databases.isEmpty {
                ContentUnavailableView("No databases found", systemImage: "externaldrive.badge.icloud")
            }
        }
    }
}

#Preview {
    DatabaseList("")
}
