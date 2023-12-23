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
            FileIconView(file.mimetype)
                .semibold()
                .frame(width: 20)
            
            Text(file.name)
        }
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
