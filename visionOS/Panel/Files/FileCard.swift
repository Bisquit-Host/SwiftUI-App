import ScrechKit
import Calagopus

struct FileCard: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(\.openWindow) private var openWindow
    
    private let id, path, mimeType, name: String
    private let file: CalagopusFileEntry
    
    init(_ id: String, file: CalagopusFileEntry, at path: String = "") {
        self.id = id
        self.file = file
        self.path = path
        
        mimeType = file.mime
        name = file.name
    }
    
    var body: some View {
        if mimeType.contains("directory") {
            NavigationLink {
                FileList(id, at: path + name + "/")
                    .environmentObject(vm)
                
                //                FolderFile(id, path: path + name)
            } label: {
                FileLabel()
            }
        } else {
            Button {
                //            if mimeType.contains("text") || mimeType.contains("json") {
                //                TextFile(id, name: name, at: path)
                //
                //            } else if mimeType.contains("video") {
                //                VideoFile(id, name: name, at: path)
                
                let link = FileLink(id, name: name, at: path)
                
                openWindow(id: "QuickLook", value: link)
            } label: {
                FileLabel()
            }
        }
    }
    
    private func FileLabel() -> some View {
        HStack {
            FileIcon(file.mime, name: file.name)
            
            HStack(alignment: .bottom) {
                Text(file.name)
#if DEBUG
                Text(file.mime)
                    .footnote()
                    .secondary()
#endif
            }
            
            Spacer()
            
            if !file.mime.contains("directory") {
                Text(formatBytes(file.size))
            }
        }
    }
}

#Preview {
    List {
        FileCard("", file: PreviewProp.fileAttributes, at: "")
    }
    .environment(NavState())
    .environmentObject(FileTabVM(""))
}
