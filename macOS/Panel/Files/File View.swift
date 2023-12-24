import ScrechKit
import PteroNet

struct FileView: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, path: String
    private let file: FileAttributes
    
    init(_ id: String,
         path: String,
         file: FileAttributes
    ) {
        self.id = id
        self.path = path
        self.file = file
    }
    
    var body: some View {
        HStack {
            FileIcon(file.mimetype)
                .semibold()
                .frame(width: 20)
            
            Text(file.name)
        }
        .padding(5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fileContextMenu(file.name,
                         path: path,
                         mimeType: file.mimetype)
    }
}

#Preview {
    FileView("",
             path: "",
             file: sampleJSON(
                .fileListAttributes
             )
    )
    .padding()
}
