import ScrechKit

struct FolderFile: View {
    @StateObject private var vm: FileTabVM
    @Environment(\.dismissSearch) private var dismissSearch
    
    private let id, path: String
    
    init(_ id: String, path: String = "") {
        self.id = id
        self.path = path
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
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
        .navigationTitle("Files")
        .toolbar {
            if !vm.files.isEmpty {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
            }
            
            PanelCodexChatToolbarItems()
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                UploadMenu(path)
            }
        }
        .searchableIf(!vm.files.isEmpty/* && !alertNewFolder*/, text: $vm.searchField)
        .hapticOn(vm.deleteSuccessHapticTrigger, as: .success)
        .environmentObject(vm)
        .frame(maxWidth: 500)
        .safariCover($vm.showSafari, url: vm.downloadURL)
        .task {
            vm.path = path
        }
        .refreshableTask {
            await vm.fetchFiles(path)
        }
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
        .overlay {
            if vm.isLoadingFiles && vm.files.isEmpty {
                ProgressView()
            } else if vm.files.isEmpty {
                ContentUnavailableView("No files yet", systemImage: "folder")
            }
        }
    }
}

#Preview {
    FolderFile("")
        .darkSchemePreferred()
}
