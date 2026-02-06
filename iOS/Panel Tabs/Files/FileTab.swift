import ScrechKit
import PhotosUI

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(PanelVM.self) private var panelVM
    
    private let id, path: String
    
    init(_ id: String, at path: String = "") {
        self.id = id
        self.path = path
    }
    
    var body: some View {
        List {
            if !vm.files.isEmpty || vm.isUploading {
                Section {
                    if !vm.files.isEmpty {
                        FileSearch($vm.searchField)
                    }
                    
                    if vm.isUploading {
                        UploadProgress()
                    }
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
            if vm.files.isEmpty {
                ContentUnavailableView("No files yet", systemImage: "folder")
            }
        }
        .task {
            vm.path = path
        }
        .refreshableTask {
            await vm.fetchFiles(path)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ImagePlaygroundButton(vm.path)
                
                SFButton("folder.badge.plus") {
                    panelVM.alertNewFolder = true
                }
                
                UploadMenu("")
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
