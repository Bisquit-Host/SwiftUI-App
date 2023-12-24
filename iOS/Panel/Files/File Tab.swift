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
    
    private var fileCount: Int {
        vm.filteredFiles.count
    }
    
    var body: some View {
        List {
            FileSearch($vm.searchField)
            
            NewFolder(path)
            
            UploadMenu($image, path: path)
            
            if vm.isUploading {
                UploadProgress(vm.uploadProgress)
            }
            
            Section {
                ForEach(vm.filteredFiles, id: \.name) { file in
                    FileView(id, file: file, path: path + "/")
                }
                .onDelete { offsets in
                    deleteItem(offsets)
                }
            } header: {
                HStack {
                    FolderPath(path)
                    
                    Spacer()
                    
                    let count = Text(fileCount)
                        .monospaced()
                    
                    Text("\(count) Files")
                }
                .numericTransition()
            }
            
            if path.isEmpty {
                FileFormats()
            }
        }
        .animation(.easeOut, value: vm.filteredFiles)
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
    FileTab("")
        .environmentObject(FileTabVM(""))
}
