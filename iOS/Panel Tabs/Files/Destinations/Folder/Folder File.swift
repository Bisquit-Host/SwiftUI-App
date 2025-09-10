import ScrechKit

struct FolderFile: View {
    @StateObject private var vm: FileTabVM
    
    private let id, path: String
    
    init(
        _ id: String,
        path: String = ""
    ) {
        self.id = id
        self.path = path
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    @State private var alertNewFolder = false
    
    var body: some View {
        List {
            Section {
                if vm.isUploading {
                    UploadProgress()
                }
            }
            
            Section {
                ForEach(vm.filteredFiles) {
                    FileView(id, file: $0, at: path)
                }
                .onDelete(perform: vm.deleteItem)
            } header: {
                FileListHeader(path)
            }
            .listRowBackground(Color.gray.opacity(0.2))
        }
        .toolbar {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            
            ToolbarSpacer(.flexible, placement: .bottomBar)
            
            ToolbarItemGroup(placement: .bottomBar) {
                ImagePlaygroundButton(path)
                
                SFButton("folder.badge.plus") {
                    alertNewFolder = true
                }
                
                UploadMenu(path)
            }
        }
        .searchable(text: $vm.searchField)
        .environmentObject(vm)
        .frame(maxWidth: 500)
        .safariCover($vm.showSafari, url: vm.downloadUrl)
        .task {
            vm.path = path
        }
        .refreshableTask {
            await vm.fetchFiles(path)
        }
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
        .alert("New Folder", isPresented: $alertNewFolder) {
            TextField("Enter a folder name", text: $vm.newFolderName)
            
            Button("Create", role: .confirm) {
                if !vm.newFolderName.isEmpty {
                    Task {
                        await vm.createFolder(vm.newFolderName, at: vm.path)
                    }
                    
                    vm.newFolderName = ""
                }
            }
            
            Button("Cancel", role: .cancel) {
                vm.newFolderName = ""
            }
        }
    }
}

#Preview {
    FolderFile("")
}
