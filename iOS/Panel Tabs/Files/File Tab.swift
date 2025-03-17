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
            
            UploadMenu($image, root: root)
            
            if vm.isUploading {
                UploadProgress()
            }
            
            Section {
                ForEach(vm.filteredFiles) { file in
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
        .toolbarBackground(.visible, for: .tabBar)
        .environmentObject(vm)
        .frame(maxWidth: 500)
        .safariCover($vm.showSafari, url: vm.downloadUrl)
        .background {
            Image(.darkBackgroundInfo)
                .resizable()
                .blur(radius: 55)
        }
        .scrollContentBackground(.hidden)
        .task {
            vm.path = root
        }
        .refreshableTask {
            vm.fetchFiles(root)
        }
        .onChange(of: image) {
            if let image {
                vm.handleImageImport(image, at: root)
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
