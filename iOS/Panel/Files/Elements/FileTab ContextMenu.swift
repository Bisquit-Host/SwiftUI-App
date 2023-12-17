import ScrechKit
import PteroNet

struct FileTab_ContextMenu: ViewModifier {
    @EnvironmentObject private var vm: FileTabVM
    
    private let file, path, mimeType: String
    
    init(_ file: String,
         path: String,
         mimeType: String
    ) {
        self.file = file
        self.path = path
        self.mimeType = mimeType
    }
    
    func body(content: Content) -> some View {
        content
            .contextMenu {
                Text(file)
                
                if !mimeType.contains("directory") {
                    Section {
                        MenuButton("Download", icon: "square.and.arrow.down") {
                            vm.downloadFile(path + "/" + file)
                        }
                    }
                }
                
                Section {
                    //                    MenuButton("Get Info", icon: "info.circle") {
                    //
                    //                    }
                    
                    //                    MenuButton("Rename", icon: "pencil") {
                    //                        print(file)
                    //                        actionFile = file
                    //                        vm.alertRename = true
                    //                    }
                    
                    if !mimeType.contains("directory") {
                        MenuButton("Duplicate", icon: "plus.square.on.square") {
                            vm.duplicateFile(file, path: path + "/")
                        }
                    }
                    
                    if mimeType.contains("gzip") {
                        MenuButton("Decompress", icon: "arrow.up.bin") {
                            vm.fileCompressor(file, path: path, action: .decompress)
                        }
                    } else {
                        MenuButton("Compress", icon: "archivebox") {
                            vm.fileCompressor(file, path: path, action: .compress)
                        }
                    }
                }
                
                if !mimeType.contains("directory") {
                    Section {
                        ShareLink(item: vm.downloadUrl) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                //                Section {
                //                    MenuButton("Delete", role: .destructive icon: "trash") {
                //
                //                    }
                //                }
            }
        //            .alert("Rename file", isPresented: $vm.alertRename) {
        //                TextField("I'm not a no-name 😢", text: $vm.newFileName)
        //                    .autocorrectionDisabled()
        //
        //                Button("Rename", role: .destructive) {
        //                    print("file: " + file)
        //                    print("actionFile: " + actionFile)
        //                    vm.renameFile(id, oldName: actionFile, newName: vm.newFileName, from: path)
        //                }
        //            }
    }
}

extension View {
    func fileContextMenu(
        _ file: String,
        path: String,
        mimeType: String
    ) -> some View {
        self.modifier(FileTab_ContextMenu(
            file,
            path: path,
            mimeType: mimeType)
        )
    }
}
