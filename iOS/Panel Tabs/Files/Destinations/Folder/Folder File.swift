import ScrechKit

struct FolderFile: View {
    @StateObject private var vm: FileTabVM
    
    private let id, path: String
    
    init(_ id: String, path: String = "") {
        self.id = id
        self.path = path
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    @State private var alertNewFolder = false
    
    var body: some View {
        List {
            Section {
                FileSearch($vm.searchField)
                
                UploadMenu(path)
            }
            .listRowBackground(Color.gray.opacity(0.2))
            
            Section {
                ForEach(vm.filteredFiles) { file in
                    FileView(id, file: file, at: path)
                }
                .onDelete(perform: deleteItem)
            } header: {
                FileListHeader(path)
            }
            .listRowBackground(Color.gray.opacity(0.2))
        }
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
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if #available(iOS 18.1, *) {
                    ImagePlaygroundButton(path)
                }
                
                Button {
                    alertNewFolder = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
            }
        }
        .alert(isPresented: $alertNewFolder) {
            CustomDialog(
                title: "New Folder",
                content: "Enter a folder name",
                image: .init(content: "folder.badge.plus", foreground: .white),
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
                textFieldHint: "Me name folder"
            )
            .transition(.blurReplace.combined(with: .scale(0.8)))
        }
    }
    
    private func deleteItem(_ offsets: IndexSet) {
        for file in offsets {
            let name = vm.filteredFiles[file].name
            
            Task {
                await vm.deleteFile(name, at: path)
            }
        }
    }
}

#Preview {
    FolderFile("")
}
