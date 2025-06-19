import ScrechKit
import PhotosUI

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, path: String
    
    init(
        _ id: String,
        at path: String = ""
    ) {
        self.id = id
        self.path = path
    }
    
    var body: some View {
        List {
            Section {
                FileSearch($vm.searchField)
                
                UploadMenu(path)
            }
            .listRowBackground(Color.gray.opacity(0.2))
            
            Section {
                ForEach(vm.filteredFiles) { file in
                    FileView(id, file: file, at: path + "/")
                }
                .onDelete(perform: deleteItem)
            } header: {
                FileListHeader(path)
            }
            .listRowBackground(Color.gray.opacity(0.2))
        }
        .animation(.easeOut, value: vm.filteredFiles)
        .environmentObject(vm)
        .frame(maxWidth: 500)
        .safariCover($vm.showSafari, url: vm.downloadUrl)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
        .task {
            vm.path = path
        }
        .refreshableTask {
            await vm.fetchFiles(path)
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
    NavigationView {
        FileTab("")
    }
    .environmentObject(FileTabVM(""))
}
