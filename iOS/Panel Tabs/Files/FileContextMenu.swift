import SwiftUI
import Calagopus
import Kingfisher

struct FileContextMenu: ViewModifier {
    @EnvironmentObject private var vm: FileTabVM
    @EnvironmentObject private var store: ValueStore
    
    private let id, path: String
    private let file: CalagopusFileEntry
    
    init(_ id: String, file: CalagopusFileEntry, at path: String) {
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
        file.mime
    }
    
    private var isArchive: Bool {
        mimeType.contains("gzip")
    }
    
    func body(content: Content) -> some View {
        content
            .contextMenu {
                if store.devMode {
                    Section {
                        Text(mimeType)
                    }
                    
                    Divider()
                }
                
                Button("Rename", systemImage: "pencil") {
                    vm.newFileName = ""
                    alertRename = true
                }
                
                Button(isArchive ? "Decompress" : "Compress", systemImage: isArchive ? "arrow.up.bin" : "archivebox") {
                    archive()
                }
                
                if !mimeType.contains("directory") {
                    Button("Duplicate", systemImage: "plus.square.on.square") {
                        duplicate()
                    }
                }
                
                Button("Permissions", systemImage: "lock.doc") {
                    sheetPermissions = true
                }
                
                Divider()
                
                if !mimeType.contains("directory") {
                    Button("Download and share", systemImage: "square.and.arrow.up") {
                        downloadAndShare()
                    }
                }
                
                Divider()
                
                Button("Delete", systemImage: "trash", role: .destructive, action: delete)
            }
            .sheet($sheetPermissions) {
                FilePermissionsParent(file, at: path)
            }
            .alert("Rename \(name)", isPresented: $alertRename) {
                TextField("I'm not a no-name 😢", text: $vm.newFileName)
                    .autocorrectionDisabled()
                    .limitInputLength($vm.newFileName, length: 255)
                
                Button("Rename", role: .destructive, action: rename)
            }
    }
    
    private func archive() {
        Task {
            await vm.fileCompressor(name, at: path, do: isArchive ? .decompress : .compress)
        }
    }
    
    private func rename() {
        Task {
            await vm.renameFile(path, from: name, to: vm.newFileName)
        }
        
        vm.newFileName = ""
    }
    
    private func delete() {
        Task {
            await vm.deleteFile(name, at: path)
        }
    }
    
    private func downloadAndShare() {
        Task {
            await vm.downloadFile(path + "/" + name)
        }
    }
    
    private func duplicate() {
        Task {
            await vm.duplicateFile(name, at: path + "/")
        }
    }
}

extension View {
    func fileContextMenu(_ id: String, file: CalagopusFileEntry, at root: String) -> some View {
        self.modifier(FileContextMenu(id, file: file, at: root))
    }
}

//#Preview {
//    @Previewable @State var link: FileLink? = FileLink("", name: "", at: "")
//
//    QuickLookFile($link)
//        .darkSchemePreferred()
//        .environmentObject(FileTabVM(""))
//}
