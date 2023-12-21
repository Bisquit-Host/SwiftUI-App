import ScrechKit

struct FolderFile: View {
    @StateObject private var vm: FileTabVM
    
    private let id, path: String
    
    init(_ id: String,
         path: String = ""
    ) {
        self.id = id
        self.path = path
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    @State private var image: UIImage?
    
    var body: some View {
        List {
            FileTabSearch($vm.fieldSearch)
            
            NewFolder(path)
            
            UploadMenu($image, path: path)
            
            if vm.isUploading {
                UploadProgress(vm.uploadProgress)
            }
            
            Section {
                ForEach(vm.filteredFiles, id: \.name) { file in
                    FileView(id, file: file, path: path)
                        .fileContextMenu(file.name,
                                         path: path,
                                         mimeType: file.mimetype)
                }
                .onDelete { offsets in
                    deleteItem(offsets)
                }
                
            } header: {
                HStack {
                    FolderPath(path)
                    
                    Spacer()
                    
                    Text("Total: \(vm.filteredFiles.count)")
                }
            }
            
            if path.isEmpty {
                FileFormats()
            }
        }
        .onChange(of: vm.fieldSearch) { _, search in
            withAnimation {
                vm.searchRule = search
            }
        }
        .environmentObject(vm)
        .frame(maxWidth: 500)
        .safariCover($vm.showSafari, url: vm.downloadUrl)
        .task {
            vm.fetchFiles(path)
        }
        .refreshable {
            vm.fetchFiles(path)
        }
        .onChange(of: image) {
            if let image {
                vm.handleImageImport(image, path: path)
            }
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
    FolderFile("")
}
