import ScrechKit

struct FileContextMenu: ViewModifier {
    @EnvironmentObject private var vm: FileTabVM
    
    @State private var alertRename = false
    
    private let name, path, mimeType: String
    
    init(_ name: String,
         path: String,
         mimeType: String
    ) {
        self.name = name
        self.path = path
        self.mimeType = mimeType
    }
    
    func body(content: Content) -> some View {
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
                            vm.downloadFile(path + name)
                        }
                    }
                    
                    MenuButton("Duplicate", icon: "doc.on.doc") {
                        vm.duplicateFile(name,
                                         path: path)
                    }
                }
                
                if mimeType.contains("gzip") {
                    MenuButton("Decompress", icon: "arrow.up.bin") {
                        vm.fileCompressor(name,
                                          path: path,
                                          action: .decompress)
                    }
                } else {
                    MenuButton("Compress", icon: "archivebox") {
                        vm.fileCompressor(name,
                                          path: path,
                                          action: .compress)
                    }
                }
                
                Section {
                    MenuButton("Delete", role: .destructive, icon: "trash") {
                        vm.fileDelete(name,
                                      path: path)
                    }
                }
            }
            .alert("Rename \(name)", isPresented: $alertRename) {
                TextField("", text: $vm.newFileName)
                
                Button("Rename", role: .destructive) {
                    vm.renameFile(path,
                                  oldName: name,
                                  newName: vm.newFileName)
                    
                    vm.newFileName = ""
                }
            }
    }
}

extension View {
    func fileContextMenu(
        _ file: String,
        path: String,
        mimeType: String
    ) -> some View {
        self.modifier(FileContextMenu(
            file,
            path: path,
            mimeType: mimeType)
        )
    }
}
