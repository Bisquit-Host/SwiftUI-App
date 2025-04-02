import ScrechKit

struct DatabaseList: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let databaseLimit: Int
    
    init(_ databaseLimit: Int = 0) {
        self.databaseLimit = databaseLimit
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        Section {
            ForEach(vm.databases) { db in
                DatabaseCard(db)
                    .environment(vm)
            }
            //            .onDelete { offsets in
            //                vm.deleteItems(.databases, offsets: offsets)
            //            }
            
            Button("Create Database") {
                vm.alertCreate = true
            }
            .foregroundStyle(.foreground)
            .disabled(vm.databases.count >= databaseLimit)
#if os(tvOS)
            .buttonStyle(.borderedProminent)
#endif
        } header: {
            if !vm.databases.isEmpty {
                SectionHeader(
                    "Databases",
                    type: .database(
                        vm.databases.count,
                        limit: databaseLimit
                    )
                )
            }
        }
    }
}

#Preview {
    List {
        DatabaseList(4)
    }
    .environment(DatabaseVM(""))
}
