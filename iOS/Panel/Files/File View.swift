import ScrechKit
import PteroNet

struct FileView: View {
    @Environment(NavState.self) private var navState
    
    private let id, path: String
    private let file: FileListAttributes
    
    init(_ id: String,
         file: FileListAttributes,
         path: String
    ) {
        self.id = id
        self.file = file
        self.path = path
    }
    
    @State private var isExtended = false
    
    private var mimeType: String {
        file.mimetype
    }
    
    private var name: String {
        file.name
    }
    
    var body: some View {
        NavigationLink {
            if mimeType.contains("text") || mimeType.contains("json") {
                TextFile(id,
                         path: path + "/",
                         name: name
                )
                
            } else if mimeType.contains("directory") {
                FolderFile(id,
                           path: path + "/" + name
                )
                
            } else if mimeType.contains("video") {
                VideoFile(id,
                          path: path + "/",
                          name: name
                )
                
            } else {
                QuickLookFile(id,
                              path: path + "/",
                              name: name
                )
            }
        } label: {
            HStack {
                FileIconView(file.mimetype)
                    .semibold()
                    .frame(width: 20)
                
                Text(file.name)
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.5)
                    .scaledToFit()
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    List {
        FileView("",
                 file: sampleJSON(.fileListAttributes),
                 path: ""
        )
        .environment(NavState())
    }
}
