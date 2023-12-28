import ScrechKit
import PteroNet

struct FileView: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, root: String
    private let file: FileAttributes
    
    init(_ id: String,
         root: String,
         file: FileAttributes
    ) {
        self.id = id
        self.root = root
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
        .fileContextMenu(file, root: root)
    }
}

#Preview {
    FileView("",
             root: "",
             file: sampleJSON(
                .fileListAttributes
             )
    )
    .padding()
}
