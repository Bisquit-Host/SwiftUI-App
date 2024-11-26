import ScrechKit

struct DatabaseList: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let databaseLimit: Int
    
    init(_ databaseLimit: Int = 0) {
        self.databaseLimit = databaseLimit
    }
    
    @State private var alertCreate = false
    
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
                alertCreate = true
            }
            .disabled(vm.databases.count >= databaseLimit)
#if os(tvOS)
            .buttonStyle(.borderedProminent)
#endif
        } header: {
            SectionHeader(
                "Databases",
                type: .database(
                    vm.databases.count,
                    limit: databaseLimit
                )
            )
        }
        
        .alert("Create Database", isPresented: $alertCreate) {
            TextField("", text: $vm.newDatabaseName)
                .autocorrectionDisabled()
            
            Button("Create") {
                vm.createDatabase()
            }
            
            Button("Cancel", role: .destructive) {
                vm.newDatabaseName = ""
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
