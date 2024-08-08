import ScrechKit

struct FolderFile: View {
    @StateObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String, path: String = "") {
        self.id = id
        self.root = path
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    @State private var image: UIImage?
    @State private var url: URL?
    
    var body: some View {
        List {
            FileSearch($vm.searchField)
            
            NewFolder(root)
            
            UploadMenu($image, url: $url, root: root)
            
            if vm.isUploading {
                UploadProgress()
            }
            
            Section {
                ForEach(vm.filteredFiles, id: \.name) { file in
                    FileView(id, file: file, root: root)
                }
                .onDelete { offsets in
                    deleteItem(offsets)
                }
            } header: {
                HStack {
                    FolderPath(root)
                    
                    Spacer()
                    
                    Text("Total: \(vm.filteredFiles.count)")
                }
            }
        }
        .environmentObject(vm)
        .frame(maxWidth: 500)
        .safariCover($vm.showSafari, url: vm.downloadUrl)
        .refreshableTask {
            vm.fetchFiles(root)
        }
        .onChange(of: image) {
            if let image {
                vm.handleImageImport(image, root: root)
            }
        }
        .onChange(of: url) {
            if let url {
                vm.handleFileImport([url], root: root)
            }
        }
    }
    
    private func deleteItem(_ offsets: IndexSet) {
        for file in offsets {
            let name = vm.filteredFiles[file].name
            
            vm.fileDelete(name, root: root)
        }
    }
}

#Preview {
    FolderFile("")
}
