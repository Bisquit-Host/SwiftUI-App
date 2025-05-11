import ScrechKit
import PteroNet

struct FileCard: View {
    private let file: FileAttributes
    
    init(_ file: FileAttributes) {
        self.file = file
    }
    
    var body: some View {
        HStack {
            FileIcon(file.mimetype)
                .semibold()
                .frame(width: 20)
            
            Text(file.name)
                .lineLimit(3)
            
            Spacer()
            
            if file.isFile {
                let size = formatBytes(file.size)
                
                Text(size)
                    .footnote()
                    .secondary()
            }
        }
    }
}

//#Preview {
//    FileCard()
//}
