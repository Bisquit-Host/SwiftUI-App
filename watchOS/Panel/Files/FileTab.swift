import ScrechKit

struct FileTab: View {
    @StateObject private var vm: FileTabVM
    @State private var alertDelete = false
    @State private var pendingDeleteFiles: [String] = []
    
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
            
            ForEach(vm.filteredFiles) { file in
                FileView(id, file: file, path: root)
                    .swipeActions {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            confirmDelete(file.name)
                        }
                        .labelStyle(.iconOnly)
                    }
            }
        }
        .navigationTitle("Files")
        .ignoresSafeArea(edges: .bottom)
        .task {
            await vm.fetchFiles(root)
        }
        .alert(deleteAlertTitle, isPresented: $alertDelete) {
            AsyncButton("Delete", role: .destructive, action: deletePendingFiles)
            
            Button("Cancel", role: .cancel) {
                pendingDeleteFiles = []
            }
        } message: {
            Text("This cannot be undone")
        }
    }
    
    private func confirmDelete(_ name: String) {
        pendingDeleteFiles = [name]
        alertDelete = true
    }
    
    private var deleteAlertTitle: String {
        if pendingDeleteFiles.count == 1, let name = pendingDeleteFiles.first {
            "Delete \(name)?"
        } else {
            "Delete \(pendingDeleteFiles.count) files?"
        }
    }
    
    private func deletePendingFiles() async {
        let files = pendingDeleteFiles
        pendingDeleteFiles = []
        
        for file in files {
            await vm.deleteFile(file, at: root)
        }
    }
}

#Preview {
    NavigationStack {
        FileTab("Preview")
    }
    .darkSchemePreferred()
}
