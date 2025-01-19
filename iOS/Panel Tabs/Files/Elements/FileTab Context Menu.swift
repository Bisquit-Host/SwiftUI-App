import ScrechKit
import PteroNet

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
                
#warning("Finish")
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
            } preview: {
                FilePreview(id, path: root, name: name)
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

import ScrechKit
import QuickLooking
import UniformTypeIdentifiers

struct FilePreview: View {
    @State private var vm: FilePreviewVM
    
    private let id, path, name: String
    
    init(_ id: String, path: String, name: String) {
        self.id = id
        self.path = path
        self.name = name
        self.vm = FilePreviewVM(id)
    }
    
    var body: some View {
        VStack {
            if let url = vm.fileUrl {
                QuickLookView(url)
                    .transition(.opacity)
            } else {
                ProgressView()
                    .frame(width: 100, height: 100)
            }
        }
        .animation(.default, value: vm.fileUrl)
        .blur(radius: vm.isSensitive ? 10 : 0)
        .task {
            vm.getFileUrl(name, at: path)
        }
        .onDisappear {
            vm.fileUrl = nil
        }
        .overlay {
            if vm.isSensitive {
                SFButton("eye.slash") {
                    withAnimation {
                        vm.isSensitive = false
                    }
                }
                .title(.semibold)
                .padding()
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            }
        }
    }
    
    private func isImage(_ url: URL) -> Bool {
        guard let fileType = UTType(filenameExtension: url.pathExtension) else {
            return false
        }
        
        return fileType.conforms(to: .image)
    }
}

@Observable
final class FilePreviewVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var fileUrl: URL? = nil
    var isSensitive = false
    
    func getFileUrl(_ file: String, at root: String) {
        fileDownloadAPI(id, path: root + "/" + file) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes.url {
                    self.downloadFile(model, name: file)
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    private func downloadFile(_ urlString: String, name: String) {
        let fm = FileManager.default
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let tempDirectoryUrl = fm.temporaryDirectory
        let destinationUrl = tempDirectoryUrl.appendingPathComponent(name)
        
        URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location, error == nil else {
                print("Download error: \(error?.localizedDescription ?? "No error description available")")
                return
            }
            
            do {
                if fm.fileExists(atPath: destinationUrl.path) {
                    try fm.removeItem(at: destinationUrl)
                }
                
                try fm.copyItem(at: location, to: destinationUrl)
                
                main {
                    self.fileUrl = destinationUrl
                    
                    Task {
                        self.loadAndCheckImage()
                    }
                }
            } catch {
                print("Error during file copy: \(error.localizedDescription)")
            }
        }
        .resume()
    }
    
    private func loadAndCheckImage() {
        let analyzer = SensitivityAnalyzer()
        
        guard let fileUrl else {
            return
        }
        
        Task {
            await analyzer.checkImage(fileUrl) { blur in
                self.isSensitive = blur
            }
        }
    }
}


//#Preview {
//    QuickLookFile("", path: "", name: "")
//        .environmentObject(FileTabVM(""))
//}
