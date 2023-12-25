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
                ForEach(vm.databases, id: \.id) { database in
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
            vm.fetchDatabases()
        }
        .onChange(of: id) {
            vm.fetchDatabases()
        }
    }
}

#Preview {
    DatabaseList("")
}
