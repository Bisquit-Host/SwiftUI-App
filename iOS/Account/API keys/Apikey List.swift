import ScrechKit

struct ApikeyList: View {
    @Environment(ApikeyVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var sheetCreate = false
    
    var body: some View {
        List {
            Section {
                ForEach(vm.keys, id: \.attributes.id) { key in
                    ApikeyCard(key)
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationTitle("My API-keys")
        .animation(.default, value: vm.keys.count)
        .refreshableTask {
            await vm.fetchKeys()
        }
        .sheet($sheetCreate) {
            CreateApikey()
        }
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissButton {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                SFButton("plus") {
                    sheetCreate = true
                }
            }
        }
    }
    
    private func deleteItems(_ offsets: IndexSet) {
        Task {
            for key in offsets {
                let id = vm.keys[key].attributes.id
                
                await vm.delete(id)
            }
        }
    }
}

#Preview {
    ApikeyList()
        .sheet {
            ApikeyList()
        }
        .darkSchemePreferred()
        .environment(ApikeyVM())
}
