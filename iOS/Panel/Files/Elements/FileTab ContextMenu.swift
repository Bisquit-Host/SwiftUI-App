import ScrechKit
import PteroNet

struct FileTab_ContextMenu: ViewModifier {
    @EnvironmentObject private var vm: FileTabVM
    
    private let file, path, mimeType, mode: String
    
    init(_ file: String,
         path: String,
         mimeType: String,
         mode: String
    ) {
        self.file = file
        self.path = path
        self.mimeType = mimeType
        self.mode = mode
    }
    
    @State private var alertRename = false
    @State private var sheetPermissions = false
    
    func body(content: Content) -> some View {
        content
            .contextMenu {
#if !os(macOS)
                Text(file)
#endif
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
                    
                    MenuButton("Rename", icon: "pencil") {
                        vm.newFileName = ""
                        alertRename = true
                    }
                    
                    if !mimeType.contains("directory") {
                        MenuButton("Duplicate", icon: "plus.square.on.square") {
                            vm.duplicateFile(file,
                                             path: path + "/")
                        }
                    }
                    
                    if mimeType.contains("gzip") {
                        MenuButton("Decompress", icon: "arrow.up.bin") {
                            vm.fileCompressor(file,
                                              path: path,
                                              action: .decompress)
                        }
                    } else {
                        MenuButton("Compress", icon: "archivebox") {
                            vm.fileCompressor(file,
                                              path: path,
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
                        vm.fileDelete(file,
                                      path: path)
                    }
                }
            }
            .sheet($sheetPermissions) {
                FilePermissionsView(mode,
                                    root: path,
                                    name: file)
            }
            .alert("Rename \(file)", isPresented: $alertRename) {
                TextField("I'm not a no-name 😢", text: $vm.newFileName)
                    .autocorrectionDisabled()
                
                Button("Rename", role: .destructive) {
                    vm.renameFile(path,
                                  oldName: file,
                                  newName: vm.newFileName)
                }
            }
    }
}

extension View {
    func fileContextMenu(
        _ file: String,
        path: String,
        mimeType: String,
        mode: String
    ) -> some View {
        self.modifier(FileTab_ContextMenu(
            file,
            path: path,
            mimeType: mimeType,
            mode: mode
        ))
    }
}
