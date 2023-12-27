import ScrechKit

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(NavState.self) private var navState
    
    private let id, path: String
    
    init(_ id: String,
         path: String = ""
    ) {
        self.id = id
        self.path = path
    }
    
    var body: some View {
        List {
            NewFolder(path)
            
            Divider()
            
            ForEach(vm.filteredFiles, id: \.name) { file in
                let name = file.name
                let mimeType = file.mimetype
                
                NavigationLink {
                    if mimeType.contains("directory") {
                        FileTab(id,
                                path: path + "/" + name)
                        .environmentObject(vm)
                        
                    } else if mimeType.contains("text") || mimeType.contains("json") {
                        TextFile(id,
                                 path: path,
                                 name: name)
                        
                    } else if mimeType.contains("image") {
                        ImageFile(id,
                                  path: path,
                                  name: name)
                        
                    } else if mimeType.contains("video") {
                        VideoFile(id,
                                  path: path,
                                  name: name)
                        
                    } else {
                        ContentUnavailableView("Warning",
                                               systemImage: "exclamationmark.triangle",
                                               description: Text("Unable to view the contents of \(name)")
                        )
                    }
                    
                    //                    navState.navigate(
                    //                        wvm.navigateBasedOnMimeType(id,
                    //                                                   path: path,
                    //                                                   file: file)
                    //                    )
                } label: {
                    FileNameAndIcon(file)
                        .fileContextMenu(file, root: path)
                }
            }
        }
        .environmentObject(vm)
        .navigationTitle(path)
        .sheet($vm.showSafari) {
            QRCodeView(vm.downloadUrl)
        }
        .task {
            vm.fetchFiles(path)
        }
    }
}

#Preview {
    FileTab("")
        .environment(NavState())
        .environmentObject(FileTabVM(""))
}
