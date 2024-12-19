import ScrechKit
import PteroNet

struct FileContextMenu: ViewModifier {
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
        let name = file.name
        let mimeType = file.mimetype
        
        content
            .contextMenu {
                MenuButton("Rename", icon: "pencil") {
                    vm.newFileName = ""
                    alertRename = true
                }
                
                if !mimeType.contains("directory") {
                    MenuButton("Download with QR", icon: "qrcode") {
                        // Context menu needs some time to close and allow the sheet to display
                        delay(0.75) {
                            vm.downloadFile(root + name)
                        }
                    }
                    
                    MenuButton("Duplicate", icon: "doc.on.doc") {
                        vm.duplicateFile(name, at: root)
                    }
                    
                    MenuButton("Permissions", icon: "lock.doc") {
                        sheetPermissions = true
                    }
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
                
                Section {
                    MenuButton("Delete", role: .destructive, icon: "trash") {
                        vm.deleteFile(name, at: root)
                    }
                }
            }
            .sheet($sheetPermissions) {
                FilePermissionsParent(file, at: root)
            }
            .alert("Rename \(name)", isPresented: $alertRename) {
                TextField("", text: $vm.newFileName)
                
                Button("Rename", role: .destructive) {
                    vm.renameFile(root, oldName: name, newName: vm.newFileName)
                    
                    vm.newFileName = ""
                }
            }
    }
}

extension View {
    func fileContextMenu(_ file: FileAttributes, root: String) -> some View {
        self.modifier(FileContextMenu(file, root: root))
    }
}
