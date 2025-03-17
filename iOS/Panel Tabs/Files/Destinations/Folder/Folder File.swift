import ScrechKit

struct FolderFile: View {
    @StateObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String, path: String = "") {
        self.id = id
        self.root = path
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    @State private var image: UIImage?
    @State private var alertNewFolder = false
    
    var body: some View {
        List {
            FileSearch($vm.searchField)
            
            UploadMenu($image, root: root)
                        
            if vm.isUploading {
                UploadProgress()
            }
            
            Section {
                ForEach(vm.filteredFiles, id: \.name) { file in
                    FileView(id, file: file, at: root)
                }
                .onDelete(perform: deleteItem)
            } header: {
                HStack {
                    FolderPath(root)
                    
                    Spacer()
                    
                    Text("\(vm.filteredFiles.count) files")
                }
            }
        }
        .environmentObject(vm)
        .frame(maxWidth: 500)
        .safariCover($vm.showSafari, url: vm.downloadUrl)
        .task {
            vm.path = root
        }
        .refreshableTask {
            vm.fetchFiles(root)
        }
        .background {
            Image(.darkBackgroundInfo)
                .resizable()
                .blur(radius: 55, opaque: true)
        }
        .scrollContentBackground(.hidden)
        .onChange(of: image) {
            if let image {
                vm.handleImageImport(image, at: root)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if #available(iOS 18.1, *) {
                    ImagePlaygroundButton(root)
                }
                
                Button {
                    alertNewFolder = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .footnote(.bold)
                        .frame(width: 35, height: 35)
                        .background(.ultraThinMaterial, in: .circle)
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, -10)
            }
        }
        .alert(isPresented: $alertNewFolder) {
            CustomDialog(
                title: "New Folder",
                content: "Enter a folder name",
                image: .init(content: "folder.badge.plus", tint: .blue, foreground: .white),
                button1: .init(content: "Create", tint: .blue, foreground: .white) { folder in
                    if !folder.isEmpty {
                        vm.createFolder(folder, at: root)
                    }
                    
                    alertNewFolder = false
                },
                button2: .init(content: "Cancel", tint: .red, foreground: .white) { _ in
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
            
            vm.deleteFile(name, at: root)
        }
    }
}

#Preview {
    FolderFile("")
}
