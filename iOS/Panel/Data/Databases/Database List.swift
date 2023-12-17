import ScrechKit

struct DatabaseList: View {
    @Environment(DataTabVM.self) private var vm
    
    private let databaseLimit: Int
    
    init(_ databaseLimit: Int = 0) {
        self.databaseLimit = databaseLimit
    }
    
    @State private var alertCreate = false
    
    var body: some View {
        @Bindable var binding = vm
        
        Section {
            ForEach(vm.databases, id: \.attributes.id) { db in
                DatabaseCard(db.attributes)
                    .environment(vm)
            }
            //            .onDelete { offsets in
            //                vm.deleteItems(.databases, offsets: offsets)
            //            }
            
            Button {
                alertCreate = true
            } label: {
                Text("Create Database")
            }
            .disabled(vm.databases.count > databaseLimit)
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
            TextField("", text: $binding.newDatabaseName)
                .autocorrectionDisabled()
            
            Button("Create") {
                vm.createDatabase()
            }
            
            Button("Cancel") {
                vm.newDatabaseName = ""
            }
        }
    }
}

#Preview {
    List {
        DatabaseList(4)
    }
    .environment(DataTabVM(""))
}
