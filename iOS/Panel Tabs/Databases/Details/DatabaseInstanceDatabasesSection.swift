import ScrechKit

struct DatabaseInstanceDatabasesSection: View {
    @Environment(DatabaseInstanceDetailsVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        Section {
            ForEach(vm.databases) {
                DatabaseInstanceDatabaseRow($0)
            }
            
            Button("Create database", systemImage: "plus") {
                vm.alertCreateDatabase = true
            }
            .disabled(vm.instance.isLocked)
        } header: {
            Text("Databases")
        }
        .alert("Create Database", isPresented: $vm.alertCreateDatabase) {
            TextField("Example", text: $vm.newDatabaseName)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .limitInputLength($vm.newDatabaseName, length: 23)
            
            AsyncButton("Create", role: .confirm, action: vm.createDatabase)
            
            Button("Cancel", role: .cancel) {
                vm.newDatabaseName = ""
            }
        } message: {
            Text("2-23 letters or numbers")
        }
    }
}

#Preview {
    List {
        DatabaseInstanceDatabasesSection()
    }
    .darkSchemePreferred()
    .environment(DatabaseInstanceDetailsVM("", instance: PreviewProp.databaseInstance))
}
