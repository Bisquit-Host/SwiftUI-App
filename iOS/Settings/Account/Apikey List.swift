import ScrechKit

struct ApikeyList: View {
    @Environment(ApikeyVM.self) private var vm
    
    @State private var sheetCreate = false
    
    var body: some View {
        NavigationView {
            List {
                ListButton("Create a new key", actionIcon: "plus") {
                    sheetCreate = true
                }
                
                Section {
                    ForEach(vm.keys, id: \.attributes.id) { attributes in
                        let key = attributes.attributes
                        
                        ApikeyCard(key)
                    }
                    .onDelete { offsets in
                        deleteItems(offsets)
                    }
                }
            }
            .navigationTitle("My API-keys")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                EditButton()
                    .fontWeight(.medium)
            }
        }
        .sheet($sheetCreate) {
            CreateApikey()
                .presentationDetents([.medium])
        }
        .task {
            vm.fetchKeys()
        }
        .refreshable {
            vm.fetchKeys()
        }
    }
    
    private func deleteItems(_ offsets: IndexSet) {
        for key in offsets {
            vm.delete(vm.keys[key].attributes.id)
        }
    }
}

#Preview {
    ApikeyList()
        .sheet(.constant(true)) {
            ApikeyList()
        }
        .environment(ApikeyVM())
}
