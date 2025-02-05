import ScrechKit
import PteroNet
import Kingfisher

struct FileTabContextMenu: ViewModifier {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id: String
    private let file: FileAttributes
    private let root: String
    
    init(
        _ id: String,
        file: FileAttributes,
        at root: String
    ) {
        self.id = id
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
                ControlGroup {
                    MenuButton("Rename", icon: "pencil") {
                        vm.newFileName = ""
                        alertRename = true
                    }
                    
                    if mimeType.contains("gzip") {
                        MenuButton("Decompress", icon: "arrow.up.bin") {
                            vm.fileCompressor(name, at: root, action: .decompress)
                        }
                    } else {
                        MenuButton("Compress", icon: "archivebox") {
                            vm.fileCompressor(name, at: root, action: .compress)
                        }
                    }
                    
                    if !mimeType.contains("directory") {
                        ShareLink(item: vm.downloadUrl) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                
#warning("File info")
                //                    MenuButton("Get Info", icon: "info.circle") {
                //
                //                    }
                
                if !mimeType.contains("directory") {
                    MenuButton("Download", icon: "square.and.arrow.down") {
                        vm.downloadFile(root + "/" + name)
                    }
                }
                
                if !mimeType.contains("directory") {
                    MenuButton("Duplicate", icon: "plus.square.on.square") {
                        vm.duplicateFile(name, at: root + "/")
                    }
                }
                
                MenuButton("Permissions", icon: "lock.doc") {
                    sheetPermissions = true
                }
                
                Divider()
                
                MenuButton("Delete", role: .destructive, icon: "trash") {
                    vm.deleteFile(name, at: root)
                }
#warning("File Preview")
                //            } preview: {
                //                FilePreview(id, path: root, name: name)
            }
            .sheet($sheetPermissions) {
                FilePermissionsParent(file, at: root)
            }
            .alert("Rename \(name)", isPresented: $alertRename) {
                TextField("I'm not a no-name 😢", text: $vm.newFileName)
                    .autocorrectionDisabled()
                
                Button("Rename", role: .destructive) {
                    vm.renameFile(root, oldName: name, newName: vm.newFileName)
                    
                    vm.newFileName = ""
                }
            }
    }
}

extension View {
    func fileContextMenu(
        _ id: String,
        file: FileAttributes,
        at root: String
    ) -> some View {
        self.modifier(FileTabContextMenu(
            id,
            file: file,
            at: root
        ))
    }
}

//#Preview {
//    QuickLookFile("", path: "", name: "")
//        .environmentObject(FileTabVM(""))
//}
