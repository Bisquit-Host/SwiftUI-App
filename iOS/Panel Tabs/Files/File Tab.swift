import ScrechKit

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String, root: String = "") {
        self.id = id
        self.root = root
    }
    
    @State private var image: UIImage?
    @State private var selectedItem: String?
    @State private var selectedIndex: Int?
    
    private var fileCount: Int {
        vm.filteredFiles.count
    }
    
    var body: some View {
        List {
            FileSearch($vm.searchField)
            
            NewFolder(root)
            
            UploadMenu($image, root: root)
            
            if #available(iOS 18.1, *) {
                ImagePlaygroundButton(root)
            }
            
            if vm.isUploading {
                UploadProgress()
            }
            
            Section {
                ForEach(vm.filteredFiles, id: \.name) { file in
                    FileView(id, file: file, at: root + "/")
                }
                .onDelete(perform: deleteItem)
            } header: {
                HStack {
                    FolderPath(root)
                    
                    Spacer()
                    
                    Text("\(fileCount) files")
                        .monospacedDigit()
                }
                .numericTransition()
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
            
            vm.deleteFile(name, at: root)
        }
    }
}

#Preview {
    NavigationView {
        FileTab("")
            .environmentObject(FileTabVM(""))
    }
}
