import ScrechKit

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, path: String
    
    init(_ id: String, at path: String = "") {
        self.id = id
        self.path = path
    }
    
    @State private var image: UIImage?
    @State private var selectedItem: String?
    @State private var selectedIndex: Int?
    @State private var trigger = false
    
    var body: some View {
        List {
            Section {
                FileSearch($vm.searchField)
                
                UploadMenu($image, at: path)
                
                if vm.isUploading {
                    UploadProgress()
                }
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
        .sensoryFeedback(.success, trigger: trigger)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
        .task {
            vm.path = path
        }
        .refreshableTask {
            await vm.fetchFiles(path)
        }
        .onChange(of: vm.isUploading) { _, newValue in
            if !newValue {
                trigger.toggle()
            }
        }
        .onChange(of: image) {
            if let image {
                Task {
                    await vm.handleImageImport(image, at: path)
                }
            }
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
