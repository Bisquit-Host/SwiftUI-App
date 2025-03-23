import ScrechKit

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(NavState.self) private var navState
    
    private let id, root: String
    
    init(_ id: String, root: String = "") {
        self.id = id
        self.root = root
    }
    
    var body: some View {
        List {
            NewFolder(root)
                .environmentObject(vm)
            
            Divider()
            
            ForEach(vm.filteredFiles, id: \.name) { file in
                let name = file.name
                let mimeType = file.mimetype
                
                NavigationLink {
                    Group {
                        if mimeType.contains("directory") {
                            FileTab(id, root: root + "/" + name)
                            
                        } else if mimeType.contains("text") || mimeType.contains("json") {
                            TextFile(id, path: root, name: name)
                            
                        } else if mimeType.contains("image") {
                            ImageFile(id, path: root, name: name)
                            
                        } else if mimeType.contains("video") {
                            VideoFile(id, name: name, at: root)
                            
                        } else if mimeType.contains("audio") {
                            AudioPlayerView(id, path: root, name: name)
                            
                        } else {
                            FileErrorView(path: root, name: name)
                        }
                    }
                    .environmentObject(vm)
                } label: {
                    FileNameAndIcon(file)
                        .fileContextMenu(file, at: root)
                }
            }
        }
        .navigationTitle(root)
        .animation(.default, value: vm.files)
        .sheet($vm.showSafari) {
            QRCodeView(vm.downloadUrl)
        }
        .task {
            vm.fetchFiles(root)
        }
    }
}

#Preview {
    FileTab("")
        .environment(NavState())
        .environmentObject(FileTabVM(""))
}
