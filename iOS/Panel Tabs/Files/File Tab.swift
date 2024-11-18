import ScrechKit

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String, root: String = "") {
        self.id = id
        self.root = root
    }
    
    @State private var image: UIImage?
    @State private var url: URL?
    @State private var selectedItem: String?
    @State private var selectedIndex: Int?
    
    private var fileCount: Int {
        vm.filteredFiles.count
    }
    
    @State private var sheetRecorder = false
    
    var body: some View {
        List {
            FileSearch($vm.searchField)
            
            NewFolder(root)
            
            UploadMenu($image, url: $url, root: root)
            
            if #available(iOS 18.1, *) {
                ImagePlaygroundButton(root)
            }
            
            if vm.isUploading {
                UploadProgress()
            }
            
#if DEBUG
            Button("Voice Memos") {
                sheetRecorder = true
            }
            .sheet($sheetRecorder) {
                AudioRecorder()
            }
#endif
            
            Section {
                ForEach(vm.filteredFiles, id: \.name) { file in
                    FileView(id, file: file, root: root + "/")
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
    NavigationView {
        FileTab("")
            .environmentObject(FileTabVM(""))
    }
}
