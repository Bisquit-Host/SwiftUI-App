import ScrechKit

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, path: String
    
    init(_ id: String,
         path: String = ""
    ) {
        self.id = id
        self.path = path
    }
    
    @State private var image: UIImage?
    
    var body: some View {
        List {
            FileTab_Search($vm.fieldSearch)
            
            FileTab_NewFolder(path)
            
            Upload_Menu($image, path: path)
            
            if vm.isUploading {
                UploadProgress(vm.uploadProgress)
            }
            
            Section {
                ForEach(vm.filteredFiles, id: \.attributes.name) { attributes in
                    let file = attributes.attributes
                    
                    FileView(id, file: file, path: path)
                        .fileContextMenu(
                            file.name,
                            path: path,
                            mimeType: file.mimetype
                        )
                }
                .onDelete { offsets in
                    deleteItem(offsets)
                }
                
            } header: {
                HStack {
                    Folder_Path(path)
                    
                    Spacer()
                    
                    Text("Total: \(vm.filteredFiles.count)")
                }
            }
            if path.isEmpty {
                FileTab_Formats()
            }
        }
        .environmentObject(vm)
        .frame(maxWidth: 500)
        .safariCover($vm.showSafari, url: vm.downloadUrl)
        .task {
            vm.fetchFiles()
        }
        .refreshable {
            vm.fetchFiles(path)
        }
        .onChange(of: vm.fieldSearch) { _, search in
            withAnimation {
                vm.searchRule = search
            }
        }
        .onChange(of: image) {
            if let image {
                vm.handleImageImport(image, directory: path)
            }
        }
    }
    
    private func deleteItem(_ offsets: IndexSet) {
        for file in offsets {
            let name = vm.filteredFiles[file].attributes.name
            
            vm.fileDelete(name, path: path)
        }
    }
}

#Preview {
    FileTab("")
        .environmentObject(FileTabVM(""))
}
