import ScrechKit
import PteroNet

struct FileContextMenu: ViewModifier {
    @EnvironmentObject private var vm: FileTabVM
    
    private let file: FileAttributes
    private let path: String
    
    init(_ file: FileAttributes, at path: String) {
        self.file = file
        self.path = path
    }
    
    @State private var alertRename = false
    @State private var sheetPermissions = false
    
    func body(content: Content) -> some View {
        let name = file.name
        let mimeType = file.mimetype
        
        content
            .contextMenu {
                Button("Rename", systemImage: "pencil") {
                    vm.newFileName = ""
                    alertRename = true
                }
                
                if !mimeType.contains("directory") {
                    Button("Download with QR", systemImage: "qrcode") {
                        // Context menu needs some time to close and allow the sheet to display
                        delay(0.75) {
                            Task {
                                await vm.downloadFile(path + name)
                            }
                        }
                    }
                    
                    Button("Duplicate", systemImage: "doc.on.doc") {
                        Task {
                            await vm.duplicateFile(name, at: path)
                        }
                    }
                    
                    Button("Permissions", systemImage: "lock.doc") {
                        sheetPermissions = true
                    }
                }
                
                if mimeType.contains("gzip") {
                    Button("Decompress", systemImage: "arrow.up.bin") {
                        Task {
                            await vm.fileCompressor(name, at: path, do: .decompress)
                        }
                    }
                } else {
                    Button("Compress", systemImage: "archivebox") {
                        Task {
                            await vm.fileCompressor(name, at: path, do: .compress)
                        }
                    }
                }
                
                Divider()
                
                Button("Delete", systemImage: "trash", role: .destructive) {
                    Task {
                        await vm.deleteFile(name, at: path)
                    }
                }
            }
            .sheet($sheetPermissions) {
                FilePermissionsParent(file, at: path)
            }
            .alert("Rename \(name)", isPresented: $alertRename) {
                TextField("", text: $vm.newFileName)
                
                Button("Rename", role: .destructive) {
                    Task {
                        await vm.renameFile(path, from: name, to: vm.newFileName)
                    }
                    
                    vm.newFileName = ""
                }
            }
    }
}

extension View {
    func fileContextMenu(_ file: FileAttributes, at path: String) -> some View {
        self.modifier(FileContextMenu(file, at: path))
    }
}
