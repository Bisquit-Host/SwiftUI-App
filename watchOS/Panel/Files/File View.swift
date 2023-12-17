import ScrechKit
import PteroNet

struct FileView: View {
    private let file: FileListAttributes
    private let id, path: String
    
    init(_ id: String,
         file: FileListAttributes,
         path: String = ""
    ) {
        self.id = id
        self.file = file
        self.path = path
    }
    
    var body: some View {
        let mimeType = file.mimetype
        let name = file.name
        
        HStack {
            NavigationLink {
                if mimeType.contains("directory") {
                    FileTab(id,
                            path: path + "/" + name
                    )
                    
                } else if mimeType.contains("text") || file.mimetype.contains("json") {
                    Des_Text(id,
                             path: path + "/",
                             name: name
                    )
                    .navigationTitle(name)
                    
                } else if mimeType.contains("image") {
                    Des_Image(id,
                              path: path + "/",
                              name: name
                    )
                    .navigationTitle(name)
                    
                } else if mimeType.contains("video") {
                    DesVideo(id,
                             path: path + "/",
                             name: name
                    )
                    .navigationTitle(name)
                } else {
                    ContentUnavailableView("Warning",
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
    FileView("", 
             file: sampleJSON(.fileListAttributes)
    )
}
