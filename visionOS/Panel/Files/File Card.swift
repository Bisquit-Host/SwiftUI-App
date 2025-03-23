import ScrechKit
import PteroNet

struct FileLink: Codable, Hashable {
    let id: String
    let name: String
    let root: String
}

struct FileCard: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(NavState.self) private var navState
    // @EnvironmentObject private var store: ValueStore
    
    @Environment(\.openWindow) private var openWindow
    
    private let id, root: String
    private let file: FileAttributes
    
    init(
        _ id: String,
        file: FileAttributes,
        at root: String = ""
    ) {
        self.id = id
        self.file = file
        self.root = root
    }
    
    var body: some View {
        let mimeType = file.mimetype
        let name = file.name
        
        if mimeType.contains("directory") {
            NavigationLink {
                FileList(id, at: root + name + "/")
                    .environmentObject(vm)
                
                //                FolderFile(id, path: root + name)
            } label: {
                FileLabel()
            }
        } else {
            Button {
                //            if mimeType.contains("text") || mimeType.contains("json") {
                //                TextFile(id, name: name, at: root)
                //
                //            } else if mimeType.contains("video") {
                //                VideoFile(id, name: name, at: root)
                
                let link = FileLink(id: id, name: name, at: root)
                
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
        FileCard("", file: sampleJSON(.fileListAttributes), root: "")
            .environment(NavState())
    }
}
