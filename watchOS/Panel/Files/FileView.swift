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
                    FileTab(id, at: root + "/" + name)
                    
                } else if mimeType.contains("text") || file.mimetype.contains("json") {
                    TextFile(id, name: name, at: root + "/")
                    
                } else if mimeType.contains("image") {
                    ImageFile(id, name: name, at: root + "/")
                    
                } else if mimeType.contains("video") {
                    VideoFile(id, name: name, at: root + "/")
                    
                } else {
                    ContentUnavailableView(
                        "Warning",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Unable to view the contents of \(name)")
                    )
                }
            } label: {
                FileNameAndIcon(file)
                    .caption()
            }
        }
        .listRowInsets(.init(top: 0, leading: 8, bottom: 0, trailing: 8))
    }
}

#Preview {
    FileView("", file: PreviewProp.fileAttributes)
        .darkSchemePreferred()
}
