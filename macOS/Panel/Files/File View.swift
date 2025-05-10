import ScrechKit
import PteroNet

struct FileView: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, root: String
    private let file: FileAttributes
    
    init(_ id: String, at root: String, file: FileAttributes) {
        self.id = id
        self.root = root
        self.file = file
    }
    
    var body: some View {
        let name = file.name
//        let mimeType = file.mimetype
        
//        Button {
            
        NavigationLink {
            QuickLookFile(id, name: name, at: root)
//            if mimeType.contains("directory") {
//                //                FolderFile(id, path: root + name + "/")
//                Text("Folder")
//                
//            } else {
//                Group {
//                    if mimeType.contains("text") || mimeType.contains("json") {
//                        //                        TextFile(id, name: name, at: root)
//                        Text("Text")
//                        
//                    } else if mimeType.contains("video") {
//                        //                        VideoFile(id, name: name, at: root)
//                        Text("Video")
//
//                    } else if mimeType.contains("audio") {
//                        //                        AudioPlayerView(id, name: name, at: root)
//                        Text("AudioPlayer")
//                        
//                    } else {
//                        //                        QuickLookFile(id, name: name, at: root)
//                        Text("QuickLook")
//                    }
//                }
//                .environmentObject(vm)
//            }
        } label: {
            HStack {
                FileIcon(file.mimetype)
                    .semibold()
                    .frame(width: 20)
                
                Text(file.name)
            }
        }
        .buttonStyle(.plain)
        .padding(5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fileContextMenu(id, file: file, at: root)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
    }
}

#Preview {
    FileView("", at: "", file: sampleJSON(.fileListAttributes))
        .padding()
}
