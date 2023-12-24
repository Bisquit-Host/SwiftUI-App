import ScrechKit

struct FileTab: View {
    @StateObject private var vm: FileTabVM
    
    private let id, path: String
    
    init(_ id: String, path: String = "") {
        self.id = id
        self.path = path
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    var body: some View {
        List {
            TextField("Search", text: $vm.searchField)
                .autocorrectionDisabled()
            
            ForEach(vm.filteredFiles, id: \.name) { file in
                FileView(id, file: file, path: path)
            }
            .onDelete { offsets in
                deleteItem(offsets)
            }
        }
        .navigationTitle("Files")
        .overlay(alignment: .bottomTrailing) {
            SFButton("arrow.triangle.2.circlepath") {
                vm.fetchFiles(path)
            }
            .headline()
            .padding(5)
            .background(.blue, in: .capsule)
            .padding(20)
            .buttonStyle(.plain)
        }
        .ignoresSafeArea(edges: .bottom)
        .task {
            vm.fetchFiles(path)
        }
    }
    
    private func deleteItem(_ offsets: IndexSet) {
        for file in offsets {
            let name = vm.filteredFiles[file].name
            
            vm.fileDelete(name, path: path)
        }
    }
}

#Preview {
    FileTab("Preview")
}
