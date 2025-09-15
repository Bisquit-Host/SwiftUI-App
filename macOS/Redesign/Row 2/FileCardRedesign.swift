import ScrechKit
import PteroNet

struct FileCardRedesign: View {
    private let file: FileAttributes
    
    init(_ file: FileAttributes) {
        self.file = file
    }
    
    var body: some View {
        HStack {
            HStack {
                FileIcon(file.mimetype)
                
                Text(file.name)
            }
            
            Text(formatBytes(file.size))
            
            Text(formatISO(file.createdAt))
                .secondary()
        }
        .padding(.vertical, 6)
    }
}

//#Preview {
//    FileCardRedesign()
//}
