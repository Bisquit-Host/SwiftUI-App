import ScrechKit

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String, at root: String = "") {
        self.id = id
        self.root = root
    }
    
    var body: some View {
        List {
            NewFolder(root)
                .environmentObject(vm)
            
            Divider()
            
            ForEach(vm.filteredFiles) { file in
                let name = file.name
                let mimeType = file.mime
                
                NavigationLink {
                    Group {
                        if mimeType.contains("directory") {
                            FileTab(id, at: root + "/" + name)
                            
                        } else if mimeType.contains("text") || mimeType.contains("json") {
                            TextFile(id, name: name, at: root)
                            
                        } else if mimeType.contains("image") {
                            ImageFile(id, name: name, at: root)
                            
                        } else if mimeType.contains("video") {
                            VideoFile(id, name: name, at: root)
                            
                        } else if mimeType.contains("audio") {
                            AudioPlayerView(id, name: name, at: root)
                            
                        } else {
                            FileErrorView(name, at: root)
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
        .animation(.default, value: vm.files.count)
        .task {
            await vm.fetchFiles(root)
        }
        .sheet($vm.showSafari) {
            QRCodeView(vm.downloadURL)
        }
    }
}

#Preview {
    NavigationStack {
        FileTab("")
    }
    .darkSchemePreferred()
    .environment(NavState())
    .environmentObject(FileTabVM(""))
}
