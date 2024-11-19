import ScrechKit
import PteroNet

struct FileView: View {
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: SettingsStorage
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, root: String
    private let file: FileAttributes
    
    init(
        _ id: String,
        file: FileAttributes,
        root: String
    ) {
        self.id = id
        self.file = file
        self.root = root
    }
    
    @State private var isExtended = false
    
    var body: some View {
        let name = file.name
        let mimeType = file.mimetype
        
        NavigationLink {
            if mimeType.contains("text") || mimeType.contains("json") {
                TextFile(id, path: root, name: name)
                
            } else if mimeType.contains("directory") {
                FolderFile(id, path: root + name)
                
            } else if mimeType.contains("video") {
                VideoFile(id, root: root, name: name)
                
            } else if mimeType.contains("audio") {
                AudioPlayerView(id, root: root, name: name)
                
            } else {
                QuickLookFile(id, root: root, name: name)
                    .environmentObject(vm)
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        FileIcon(mimeType, name: name)
                            .semibold()
                            .frame(width: 20)
                        
                        Text(name)
                            .foregroundStyle(.primary)
                            .minimumScaleFactor(0.5)
                            .scaledToFit()
                            .lineLimit(1)
                    }
                    
                    if settings.adminMode {
                        Text(mimeType)
                            .footnote()
                            .secondary()
                    }
                }
                
                Spacer()
                
                let size = formatBytes(file.size)
                
                Text(size)
                    .footnote()
                    .secondary()
            }
        }
        .fileContextMenu(file, root: root)
    }
}

#Preview {
    List {
        FileView("", file: sampleJSON(.fileListAttributes), root: "")
            .environment(NavState())
    }
}
