import ScrechKit
import PteroNet

struct FileView: View {
    @Environment(NavState.self) private var navState
    
    private let id, path: String
    private let file: FileAttributes
    
    init(_ id: String,
         file: FileAttributes,
         path: String
    ) {
        self.id = id
        self.file = file
        self.path = path
    }
    
    @State private var isExtended = false
    
    var body: some View {
        let name = file.name
        let mimeType = file.mimetype
        
        NavigationLink {
            if mimeType.contains("text") || mimeType.contains("json") {
                TextFile(id,
                         path: path,
                         name: name
                )
                
            } else if mimeType.contains("directory") {
                FolderFile(id,
                           path: path + name)
                
            } else if mimeType.contains("video") {
                VideoFile(id,
                          path: path,
                          name: name)
                
            } else {
                QuickLookFile(id,
                              path: path,
                              name: name)
            }
        } label: {
            HStack {
                FileIcon(mimeType)
                    .semibold()
                    .frame(width: 20)
                
                Text(name)
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.5)
                    .scaledToFit()
                    .lineLimit(1)
            }
        }
        .fileContextMenu(file, root: path)
    }
}

#Preview {
    List {
        FileView("",
                 file: sampleJSON(.fileListAttributes),
                 path: "")
        .environment(NavState())
    }
}
