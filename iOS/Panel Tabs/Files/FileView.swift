import ScrechKit
import Calagopus

struct FileView: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, root: String
    private let file: FileAttributes
    
    init(_ id: String, file: FileAttributes, at root: String) {
        self.id = id
        self.file = file
        self.root = root
    }
    
    var body: some View {
        let name = file.name
        let mimeType = file.mimetype
        
        NavigationLink {
            if mimeType.contains("directory") {
                FolderFile(id, path: root + name + "/")
            } else {
                Group {
                    if mimeType.contains("text") || mimeType.contains("json") {
                        TextFile(id, name: name, at: root)
                        
                    } else if mimeType.contains("video") {
                        VideoFile(id, name: name, at: root)
                        
                    } else if mimeType.contains("audio") {
                        AudioPlayerView(id, name: name, at: root)
                        
                    } else {
                        QuickLookFile(id, name: name, at: root)
                    }
                }
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
                            .minimumScaleFactor(0.75)
                            .scaledToFit()
                            .lineLimit(1)
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
        }
        .fileContextMenu(id, file: file, at: root)
    }
}

#Preview {
    List {
        FileView("", file: PreviewProp.fileAttributes, at: "")
    }
    .darkSchemePreferred()
    .environment(NavState())
    .environmentObject(FileTabVM(""))
}
