import ScrechKit

struct CalagopusAPIKeyListView: View {
    @Environment(CalagopusAPIKeyVM.self) private var vm
    
    @State private var sheetCreate = false
    
    var body: some View {
        List {
            Section {
                ForEach(vm.keys) {
                    CalagopusAPIKeyCardView($0)
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationTitle("API keys")
        .animation(.default, value: vm.keys.count)
        .refreshableTask {
            await vm.fetchKeys()
        }
        .sheet($sheetCreate) {
            NavigationStack {
                CalagopusAPIKeyCreateView()
            }
            .environment(vm)
        }
        .scrollContentBackground(.hidden)
        .overlay {
            if vm.keys.isEmpty {
                ContentUnavailableView(
                    "No API keys have been created yet",
                    systemImage: "key.2.on.ring.fill",
                    description: Text("Use the button in the top right corner to create one")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SFButton("plus") {
                    sheetCreate = true
                }
            }
        }
    }
    
    private func deleteItems(_ offsets: IndexSet) {
        for index in offsets {
            let id = vm.keys[index].id
            
            Task {
                await vm.delete(id)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CalagopusAPIKeyListView()
    }
    .darkSchemePreferred()
    .environment(CalagopusAPIKeyVM())
}
