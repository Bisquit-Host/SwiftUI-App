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
                ForEach(vm.filteredFiles) { file in
                    FileView(id, file: file, at: path)
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
        .alert(isPresented: $alertNewFolder) {
            CustomDialog(
                title: "New Folder",
                button1: .init(content: "Create", foreground: .white) { folder in
                    if !folder.isEmpty {
                        Task {
                            await vm.createFolder(folder, at: path)
                        }
                    }
                    
                    alertNewFolder = false
                },
                button2: .init(content: "Cancel", foreground: .white) { _ in
                    alertNewFolder = false
                },
                addsTextField: true,
                textFieldHint: "Enter a folder name"
            )
            .transition(.blurReplace.combined(with: .scale(0.8)))
        }
    }
}

#Preview {
    FolderFile("")
}
