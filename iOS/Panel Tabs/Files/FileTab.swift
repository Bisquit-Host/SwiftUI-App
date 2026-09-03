import ScrechKit

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.panelToolbarButtonsVisible) private var toolbarButtonsVisible
    
    @State private var alertNewFolder = false
    @State private var alertDelete = false
    @State private var newFolderName = ""
    @State private var pendingDeleteFiles: [String] = []
    
    private let id, path: String
    
    init(_ id: String, at path: String = "") {
        self.id = id
        self.path = path
    }
    
    var body: some View {
        List {
            if vm.isUploading {
                Section {
                    UploadProgress()
                }
            }
            
            Section {
                ForEach(vm.filteredFiles) { file in
                    FileView(id, file: file, at: path + "/")
                        .swipeActions {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                confirmDelete(file.name)
                            }
                            .labelStyle(.iconOnly)
                        }
                }
            } header: {
                FileListHeader(path)
            }
        }
        .animation(.easeOut, value: vm.filteredFiles.count)
        .hapticOn(vm.deleteSuccessHapticTrigger, as: .success)
        .environmentObject(vm)
        .frame(maxWidth: 500)
        .safariCover($vm.showSafari, url: vm.downloadURL)
        .overlay {
            if vm.isLoadingFiles && vm.files.isEmpty {
                ProgressView()
            } else if vm.files.isEmpty {
                ContentUnavailableView("No files yet", systemImage: "folder")
            }
        }
        .task {
            vm.path = path
        }
        .refreshableTask {
            await vm.fetchFiles(path)
        }
        .searchableIf(!vm.files.isEmpty && !alertNewFolder, text: $vm.searchField)
        .toolbar {
            if !vm.files.isEmpty && toolbarButtonsVisible {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
            }
            
            AgentChatToolbarItems()
            
            PanelToolbarItem(placement: .topBarTrailing) {
                UploadMenu("")
            }
        }
        .alert(deleteAlertTitle, isPresented: $alertDelete) {
            Button("Delete", role: .destructive, action: deletePendingFiles)
            Button("Cancel", role: .cancel) {
                pendingDeleteFiles = []
            }
        } message: {
            Text("This cannot be undone")
        }
    }
    
    private var deleteAlertTitle: String {
        if pendingDeleteFiles.count == 1, let name = pendingDeleteFiles.first {
            return "Delete \(name)?"
        }
        
        return "Delete \(pendingDeleteFiles.count) files?"
    }
    
    private func confirmDelete(_ name: String) {
        pendingDeleteFiles = [name]
        alertDelete = true
    }
    
    private func deletePendingFiles() {
        let files = pendingDeleteFiles
        pendingDeleteFiles = []
        
        Task {
            for file in files {
                await vm.deleteFile(file, at: path)
            }
        }
    }
}

#Preview {
    NavigationStack {
        FileTab("")
    }
    .darkSchemePreferred()
    .environmentObject(FileTabVM(""))
}
