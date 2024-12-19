import ScrechKit
import PteroNet

struct FileView: View {
    private let file: FileAttributes
    private let id, root: String
    
    init(_ id: String, file: FileAttributes, path: String = "") {
        self.id = id
        self.file = file
        self.root = path
    }
    
    var body: some View {
        let mimeType = file.mimetype
        let name = file.name
        
        HStack {
            NavigationLink {
                if mimeType.contains("directory") {
                    FileTab(id, root: root + "/" + name)
                    
                } else if mimeType.contains("text") || file.mimetype.contains("json") {
                    TextFile(id, path: root + "/", name: name)
                    
                } else if mimeType.contains("image") {
                    ImageFile(id, path: root + "/", name: name)
                    
                } else if mimeType.contains("video") {
                    VideoFile(id, path: root + "/", name: name)
                    
                } else {
                    ContentUnavailableView(
                        "Warning",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Unable to view the contents of \(name)")
                    )
                }
            } label: {
                FileNameAndIcon(file)
            }
        }
    }
}

#Preview {
    FileView("", file: sampleJSON(.fileListAttributes))
}
