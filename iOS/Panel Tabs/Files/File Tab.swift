import ScrechKit

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String,
         root: String = ""
    ) {
        self.id = id
        self.root = root
    }
    
    @State private var image: UIImage?
    
    private var fileCount: Int {
        vm.filteredFiles.count
    }
    
    var body: some View {
        List {
            FileSearch($vm.searchField)
            
            NewFolder(root)
            
            UploadMenu($image, root: root)
            
            if vm.isUploading {
                UploadProgress()
            }
            
            Section {
                ForEach(vm.filteredFiles, id: \.name) { file in
                    FileView(id,
                             file: file,
                             root: root + "/")
                }
                .onDelete { offsets in
                    deleteItem(offsets)
                }
            } header: {
                HStack {
                    FolderPath(root)
                    
                    Spacer()
                    
                    let count = Text(fileCount)
                        .monospaced()
                    
                    Text("\(count) Files")
                }
                .numericTransition()
            }
            
            if root.isEmpty {
                FileFormats()
            }
        }
        .animation(.easeOut, value: vm.filteredFiles)
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
    }
    
    private func deleteItem(_ offsets: IndexSet) {
        for file in offsets {
            let name = vm.filteredFiles[file].name
            
            vm.fileDelete(name, root: root)
        }
    }
}

#Preview {
    FileTab("")
        .environmentObject(FileTabVM(""))
}
