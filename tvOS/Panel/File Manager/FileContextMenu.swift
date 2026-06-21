import ScrechKit
import Calagopus

struct FileContextMenu: ViewModifier {
    @EnvironmentObject private var vm: FileTabVM
    
    private let file: FileAttributes
    private let path: String
    private let name: String
    private let mimeType: String
    private let isArchive: Bool
    
    init(_ file: FileAttributes, at path: String) {
        self.file = file
        self.path = path
        isArchive = file.mimetype.contains("gzip")
        self.name = file.name
        self.mimeType = file.mimetype
    }
    
    @State private var alertRename = false
    @State private var sheetPermissions = false
    
    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button("Rename", systemImage: "pencil") {
                    vm.newFileName = ""
                    alertRename = true
                }
                
                if !mimeType.contains("directory") {
                    Button("Download with QR", systemImage: "qrcode") {
                        Task {
                            // Context menu needs some time to close and allow the sheet to display
                            try? await Task.sleep(for: .seconds(0.75))

                            await vm.downloadFile(path + name)
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
                
                Button(isArchive ? "Decompress" : "Compress", systemImage: isArchive ? "arrow.up.bin" : "archivebox") {
                    Task {
                        await vm.fileCompressor(name, at: path, do: isArchive ? .decompress : .compress)
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
                
                Button("Rename", role: .destructive, action: rename)
            }
    }
    
    private func rename() {
        Task {
            await vm.renameFile(path, from: name, to: vm.newFileName)
        }
        
        vm.newFileName = ""
    }
}

extension View {
    func fileContextMenu(_ file: FileAttributes, at path: String) -> some View {
        self.modifier(FileContextMenu(file, at: path))
    }
}
