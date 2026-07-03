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
        .alert(deleteAlertTitle, isPresented: $alertDelete) {
            Button("Delete", role: .destructive, action: deletePendingFiles)
            Button("Cancel", role: .cancel) {
                pendingDeleteFiles = []
            }
        } message: {
            Text("This cannot be undone")
        }
    }
    
    private func deleteItem(_ offsets: IndexSet) {
        pendingDeleteFiles = offsets.map {
            vm.filteredFiles[$0].name
        }
        alertDelete = true
    }
    
    private var deleteAlertTitle: String {
        if pendingDeleteFiles.count == 1, let name = pendingDeleteFiles.first {
            return "Delete \(name)?"
        }
        
        return "Delete \(pendingDeleteFiles.count) files?"
    }
    
    private func deletePendingFiles() {
        let files = pendingDeleteFiles
        pendingDeleteFiles = []
        
        Task {
            for file in files {
                await vm.deleteFile(file, at: root)
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
