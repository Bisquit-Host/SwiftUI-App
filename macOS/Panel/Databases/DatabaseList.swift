import SwiftUI

struct DatabaseList: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(vm.databases) {
                    DatabaseCard($0)
                }
            }
        }
        .navigationTitle("Databases")
        .scrollIndicators(.never)
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
    NavigationStack {
        DatabaseList("")
    }
    .darkSchemePreferred()
    .environment(DatabaseVM(""))
}
