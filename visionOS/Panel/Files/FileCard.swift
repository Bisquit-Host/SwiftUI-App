import ScrechKit
import PteroNet

struct FileCard: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(NavState.self) private var navState
    
    @Environment(\.openWindow) private var openWindow
    
    private let id, path: String
    private let file: FileAttributes
    
    init(
        _ id: String,
        file: FileAttributes,
        at path: String = ""
    ) {
        self.id = id
        self.file = file
        self.path = path
    }
    
    var body: some View {
        let mimeType = file.mimetype
        let name = file.name
        
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
            FileIcon(file.mimetype, name: file.name)
            
            HStack(alignment: .bottom) {
                Text(file.name)
#if DEBUG
                Text(file.mimetype)
                    .footnote()
                    .secondary()
#endif
            }
            
            Spacer()
            
            if !file.mimetype.contains("directory") {
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
