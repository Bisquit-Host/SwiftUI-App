import ScrechKit
import PteroNet

struct FileView: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, path: String
    private let file: FileListAttributes
    
    init(_ id: String,
         path: String,
         file: FileListAttributes
    ) {
        self.id = id
        self.path = path
        self.file = file
    }
    
    var body: some View {
        HStack {
            FileIconView(file.mimetype)
            
            Text(file.name)
        }
        .contextMenu {
            MenuButton("Duplicate", icon: "doc.on.doc") {
                vm.duplicateFile(file.name, path: path)
            }
        }
    }
}

#Preview {
    FileView(
        "",
        path: "",
        file: sampleJSON(.fileListAttributes)
    )
    .padding()
}
