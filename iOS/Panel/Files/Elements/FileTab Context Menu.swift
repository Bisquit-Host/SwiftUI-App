import ScrechKit
import PteroNet

struct FileTabContextMenu: ViewModifier {
    @EnvironmentObject private var vm: FileTabVM
    
    private let file: FileAttributes
    private let root: String
    
    init(_ file: FileAttributes,
         root: String
    ) {
        self.file = file
        self.root = root
    }
    
    @State private var alertRename = false
    @State private var sheetPermissions = false
    
    func body(content: Content) -> some View {
        let mimeType = file.mimetype
        let name = file.name
        
        content
            .contextMenu {
#if !os(macOS)
                Text(name)
#endif
                if !mimeType.contains("directory") {
                    Section {
                        MenuButton("Download", icon: "square.and.arrow.down") {
                            vm.downloadFile(root + "/" + name)
                        }
                    }
                }
                
                Section {
                    //                    MenuButton("Get Info", icon: "info.circle") {
                    //
                    //                    }
                    
                    MenuButton("Rename", icon: "pencil") {
                        vm.newFileName = ""
                        alertRename = true
                    }
                    
                    if !mimeType.contains("directory") {
                        MenuButton("Duplicate", icon: "plus.square.on.square") {
                            vm.duplicateFile(name, root: root + "/")
                        }
                    }
                    
                    if mimeType.contains("gzip") {
                        MenuButton("Decompress", icon: "arrow.up.bin") {
                            vm.fileCompressor(name,
                                              root: root,
                                              action: .decompress)
                        }
                    } else {
                        MenuButton("Compress", icon: "archivebox") {
                            vm.fileCompressor(name,
                                              root: root,
                                              action: .compress)
                        }
                    }
                    
                    MenuButton("Permissions", icon: "lock.doc") {
                        sheetPermissions = true
                    }
                }
                
                if !mimeType.contains("directory") {
                    Section {
                        ShareLink(item: vm.downloadUrl) {
                            Label("Share...", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                
                Section {
                    MenuButton("Delete", role: .destructive, icon: "trash") {
                        vm.fileDelete(name, root: root)
                    }
                }
            }
            .sheet($sheetPermissions) {
                FilePermissionsParent(file, root: root)
            }
            .alert("Rename \(name)", isPresented: $alertRename) {
                TextField("I'm not a no-name 😢", text: $vm.newFileName)
                    .autocorrectionDisabled()
                
                Button("Rename", role: .destructive) {
                    vm.renameFile(root,
                                  oldName: name,
                                  newName: vm.newFileName)
                    
                    vm.newFileName = ""
                }
            }
    }
}

extension View {
    func fileContextMenu(
        _ file: FileAttributes,
        root: String
    ) -> some View {
        self.modifier(FileTabContextMenu(
            file,
            root: root
        ))
    }
}
