import ScrechKit
import PteroNet
import Kingfisher

struct FileContextMenu: ViewModifier {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, path: String
    private let file: FileAttributes
    
    init(
        _ id: String,
        file: FileAttributes,
        at path: String
    ) {
        self.id = id
        self.file = file
        self.path = path
    }
    
    @State private var alertRename = false
    @State private var sheetPermissions = false
    
    private var name: String {
        file.name
    }
    
    private var mimeType: String {
        file.mimetype
    }
    
    func body(content: Content) -> some View {
        content
            .contextMenu {
                RenameButton()
                
                CompressButton()
                
                if !mimeType.contains("directory") {
                    MenuButton("Duplicate", icon: "plus.square.on.square") {
                        Task {
                            await vm.duplicateFile(name, at: path + "/")
                        }
                    }
                }
                
                MenuButton("Permissions", icon: "lock.doc") {
                    sheetPermissions = true
                }
                
                Divider()
                
                if !mimeType.contains("directory") {
                    MenuButton("Download", icon: "square.and.arrow.down") {
                        Task {
                            await vm.downloadFile(path + "/" + name)
                        }
                    }
                }
                
                if !mimeType.contains("directory") {
                    ShareButton()
                }
                
                Divider()
                
                MenuButton("Delete", role: .destructive, icon: "trash") {
                    Task {
                        await vm.deleteFile(name, at: path)
                    }
                }
            }
            .sheet($sheetPermissions) {
                FilePermissionsParent(file, at: path)
            }
            .alert("Rename \(name)", isPresented: $alertRename) {
                TextField("I'm not a no-name 😢", text: $vm.newFileName)
                    .autocorrectionDisabled()
                    .limitInputLength($vm.newFileName, length: 255)
                
                Button("Rename", role: .destructive) {
                    Task {
                        await vm.renameFile(path, from: name, to: vm.newFileName)
                    }
                    
                    vm.newFileName = ""
                }
            }
    }
    
    private func RenameButton() -> some View {
        MenuButton("Rename", icon: "pencil") {
            vm.newFileName = ""
            alertRename = true
        }
    }
    
    private func CompressButton() -> some View {
        if mimeType.contains("gzip") {
            MenuButton("Decompress", icon: "arrow.up.bin") {
                Task {
                    await vm.fileCompressor(name, at: path, do: .decompress)
                }
            }
        } else {
            MenuButton("Compress", icon: "archivebox") {
                Task {
                    await vm.fileCompressor(name, at: path, do: .compress)
                }
            }
        }
    }
    
    private func ShareButton() -> some View {
        ShareLink(item: vm.downloadUrl)
    }
}

extension View {
    func fileContextMenu(
        _ id: String,
        file: FileAttributes,
        at root: String
    ) -> some View {
        self.modifier(FileContextMenu(
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
