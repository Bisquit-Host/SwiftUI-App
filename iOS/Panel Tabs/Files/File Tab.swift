import ScrechKit

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String, at root: String = "") {
        self.id = id
        self.root = root
    }
    
    @State private var image: UIImage?
    @State private var selectedItem: String?
    @State private var selectedIndex: Int?
    @State private var trigger = false
    
    private var fileCount: Int {
        vm.filteredFiles.count
    }
    
    var body: some View {
        List {
            Section {
                FileSearch($vm.searchField)
                
                UploadMenu($image, at: root)
                
                if vm.isUploading {
                    UploadProgress()
                }
            }
            .listRowBackground(Color.gray.opacity(0.2))
            
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
            .listRowBackground(Color.gray.opacity(0.2))
        }
        .animation(.easeOut, value: vm.filteredFiles)
        .toolbarBackground(.visible, for: .tabBar)
        .environmentObject(vm)
        .frame(maxWidth: 500)
        .safariCover($vm.showSafari, url: vm.downloadUrl)
        .sensoryFeedback(.success, trigger: trigger)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
        .task {
            vm.path = root
        }
        .refreshableTask {
            vm.fetchFiles(root)
        }
        .onChange(of: vm.isUploading) { _, newValue in
            if !newValue {
                trigger.toggle()
            }
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
