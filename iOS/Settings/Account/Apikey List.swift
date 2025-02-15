import ScrechKit

struct ApikeyList: View {
    @Environment(ApikeyVM.self) private var vm
    
    @State private var sheetCreate = false
    
    var body: some View {
        List {
            ListButton("Create a new key", actionIcon: "plus") {
                sheetCreate = true
            }
            
            Section {
                ForEach(vm.keys, id: \.attributes.id) { key in
                    ApikeyCard(key)
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationTitle("My API-keys")
        .toolbarTitleDisplayMode(.inline)
        .animation(.default, value: vm.keys.count)
        .toolbar {
            EditButton()
        }
        .refreshableTask {
            vm.fetchKeys()
        }
        .sheet($sheetCreate) {
            CreateApikey()
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
        .sheet {
            ApikeyList()
        }
        .environment(ApikeyVM())
        .environmentObject(ValueStore())
}
