import ScrechKit

struct FileTab: View {
    @StateObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String, at root: String = "") {
        self.id = id
        self.root = root
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    var body: some View {
        List {
            TextField("Search", text: $vm.searchField)
                .autocorrectionDisabled()
                .listRowBackground(Color.clear)
            
            ForEach(vm.filteredFiles) {
                FileView(id, file: $0, path: root)
            }
            .onDelete(perform: deleteItem)
        }
        .navigationTitle("Files")
        .ignoresSafeArea(edges: .bottom)
        .task {
            await vm.fetchFiles(root)
        }
    }
    
    private func deleteItem(_ offsets: IndexSet) {
        for file in offsets {
            let name = vm.filteredFiles[file].name
            
            Task {
                await vm.deleteFile(name, at: root)
            }
        }
    }
}

#Preview {
    NavigationStack {
        FileTab("Preview")
    }
    .darkSchemePreferred()
}
