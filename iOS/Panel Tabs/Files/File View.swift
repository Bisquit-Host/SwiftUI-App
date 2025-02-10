import ScrechKit
import PteroNet

struct FileView: View {
    @EnvironmentObject private var store: ValueStore
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, root: String
    private let file: FileAttributes
    
    init(
        _ id: String,
        file: FileAttributes,
        at root: String
    ) {
        self.id = id
        self.file = file
        self.root = root
    }
    
    @State private var isExtended = false
    @Namespace private var namespace
    
    var body: some View {
        let name = file.name
        let mimeType = file.mimetype
        
        NavigationLink {
            if mimeType.contains("directory") {
                FolderFile(id, path: root + name + "/")
                
            } else {
                Group {
                    if mimeType.contains("text") || mimeType.contains("json") {
                        TextFile(id, path: root, name: name)
                        
                    } else if mimeType.contains("video") {
                        VideoFile(id, path: root, name: name)
                        
                    } else if mimeType.contains("audio") {
                        AudioPlayerView(id, path: root, name: name)
                        
                    } else {
                        QuickLookFile(id, path: root, name: name)
                    }
                }
                .environmentObject(vm)
                .navigationZoomTransition("zoom", in: namespace)
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
                    
                    if store.devMode {
                        Text(mimeType)
                            .footnote()
                            .secondary()
                    }
                }
                
                Spacer()
                
                if file.isFile {
                    let size = formatBytes(file.size)
                    
                    Text(size)
                        .footnote()
                        .secondary()
                }
            }
            .matchedTransitionSource("zoom", in: namespace)
        }
        .fileContextMenu(id, file: file, at: root)
    }
}

#Preview {
    List {
        FileView("", file: sampleJSON(.fileListAttributes), at: "")
    }
    .environment(NavState())
    .environmentObject(FileTabVM(""))
}
