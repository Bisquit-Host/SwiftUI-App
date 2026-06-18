import ScrechKit
import PhotosUI

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(\.dismissSearch) private var dismissSearch
    
    @State private var alertNewFolder = false
    @State private var newFolderName = ""
    
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
                .listRowBackground(Color.gray.opacity(0.2))
            }
            
            Section {
                ForEach(vm.filteredFiles) {
                    FileView(id, file: $0, at: path + "/")
                }
                .onDelete(perform: vm.deleteItem)
            } header: {
                FileListHeader(path)
            }
            .listRowBackground(Color.gray.opacity(0.2))
        }
        .animation(.easeOut, value: vm.filteredFiles)
        .environmentObject(vm)
        .frame(maxWidth: 500)
        .safariCover($vm.showSafari, url: vm.downloadURL)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
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
            ToolbarItemGroup(placement: .topBarTrailing) {
                ImagePlaygroundButton(vm.path)
                
                SFButton("folder.badge.plus") {
                    dismissSearch()
                    
                    Task {
                        await Task.yield()
                        alertNewFolder = true
                    }
                }
                
                UploadMenu("")
            }
        }
        .alert("New Folder", isPresented: $alertNewFolder) {
            TextField("Enter a folder name", text: $newFolderName)
            Button("Create", role: .confirmy, action: createFolder)
            
            Button("Cancel", role: .cancel) {
                newFolderName = ""
            }
        }
    }    
    
    private func createFolder() {
        let folderName = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !folderName.isEmpty {
            Task {
                await vm.createFolder(folderName, at: vm.path)
            }
            
            newFolderName = ""
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
