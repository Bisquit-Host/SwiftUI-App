import SwiftUI
import Calagopus
import Kingfisher
#if os(iOS)
import UIKit
#endif

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
    @State private var sheetArchiveFormat = false
#if os(iOS)
    @State private var shareURL: FileShareURL? = nil
#endif
    
    private var name: String {
        file.name
    }
    
    private var mimeType: String {
        file.mime
    }
    
    private var isArchive: Bool {
        let fileName = name.lowercased()
        return [
            "application/vnd.rar",
            "application/x-rar-compressed",
            "application/x-tar",
            "application/x-br",
            "application/x-bzip2",
            "application/gzip",
            "application/x-gzip",
            "application/x-lz4",
            "application/x-xz",
            "application/x-lzip",
            "application/zstd",
            "application/zip",
            "application/x-7z-compressed"
        ].contains(mimeType) || fileName.hasSuffix(".ddup") || fileName.hasSuffix(".pxar")
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
            .sheet($sheetArchiveFormat) {
                ArchiveFormatSheet(fileName: name) {
                    archive(name: $0, format: $1)
                }
            }
#if os(iOS)
            .sheet(item: $shareURL) {
                FileActivityView(url: $0.url)
                    .ignoresSafeArea()
            }
#endif
            .alert("Rename \(name)", isPresented: $alertRename) {
                TextField("I'm not a no-name 😢", text: $vm.newFileName)
                    .autocorrectionDisabled()
                    .limitInputLength($vm.newFileName, length: 255)
                
                Button("Rename", role: .destructive, action: rename)
            }
    }
    
    private func archive() {
        if isArchive {
            Task {
                await vm.fileCompressor(name, at: path, do: .decompress)
            }
        } else {
            sheetArchiveFormat = true
        }
    }
    
    private func archive(name: String, format: CalagopusFileArchiveFormat) {
        Task {
            await vm.fileCompressor(self.name, at: path, do: .compress, format: format, name: name)
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
#if os(iOS)
            shareURL = await vm.localFileForSharing(path + "/" + name, name: name).map {
                FileShareURL(url: $0)
            }
#else
            await vm.downloadFile(path + "/" + name)
#endif
        }
    }
    
    private func duplicate() {
        Task {
            await vm.duplicateFile(name, at: path + "/")
        }
    }
}

#if os(iOS)
private struct FileShareURL: Identifiable {
    let url: URL
    
    var id: URL {
        url
    }
}

private struct FileActivityView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

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
