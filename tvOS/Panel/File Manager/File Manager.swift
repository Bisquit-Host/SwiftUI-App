import ScrechKit

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(NavState.self) private var navState
    
    private let id, root: String
    
    init(_ id: String,
         root: String = ""
    ) {
        self.id = id
        self.root = root
    }
    
    var body: some View {
        List {
            NewFolder(root)
            
            Divider()
            
            ForEach(vm.filteredFiles, id: \.name) { file in
                let name = file.name
                let mimeType = file.mimetype
                
                NavigationLink {
                    if mimeType.contains("directory") {
                        FileTab(id, root: root + "/" + name)
                            .environmentObject(vm)
                        
                    } else if mimeType.contains("text") || mimeType.contains("json") {
                        TextFile(id, path: root, name: name)
                            .environmentObject(vm)
                        
                    } else if mimeType.contains("image") {
                        ImageFile(id, path: root, name: name)
                            .environmentObject(vm)
                        
                    } else if mimeType.contains("video") {
                        VideoFile(id, path: root, name: name)
                            .environmentObject(vm)
                        
                    } else {
                        ContentUnavailableView(
                            "Warning",
                            systemImage: "exclamationmark.triangle",
                            description: Text("Unable to view the contents of \(name)")
                        )
                    }
                    
                    //                    navState.navigate(
                    //                        wvm.navigateBasedOnMimeType(id,
                    //                                                   root: root,
                    //                                                   file: file)
                    //                    )
                } label: {
                    FileNameAndIcon(file)
                        .fileContextMenu(file, root: root)
                }
            }
        }
        .environmentObject(vm)
        .navigationTitle(root)
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
