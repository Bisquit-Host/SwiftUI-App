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
                .onDelete { indexSet in
                    Task {
                        await deleteItems(indexSet)
                    }
                }

            }
            .transparentSection()
        }
        .navigationTitle("My API-keys")
        .transparentList()
        .toolbarBackground(.visible, for: .tabBar)
        .animation(.default, value: vm.keys.count)
        .refreshableTask {
            await vm.fetchKeys()
        }
        .sheet($sheetCreate) {
            CreateApikey()
        }
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissButton {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    sheetCreate = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.foreground)
                        .footnote(.bold)
                        .frame(35)
                        .background(.ultraThinMaterial, in: .circle)
                }
            }
        }
    }
    
    private func deleteItems(_ offsets: IndexSet) async {
        for key in offsets {
            await vm.delete(vm.keys[key].attributes.id)
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
