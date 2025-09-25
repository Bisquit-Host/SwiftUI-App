import ScrechKit
import PteroNet

struct FileCardRedesign: View {
    private let file: FileAttributes
    
    init(_ file: FileAttributes) {
        self.file = file
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Group {
                HStack {
                    FileIcon(file.mimetype)
                    
                    Text(file.name)
                }
                
                Text(formatBytes(file.size))
                    .secondary()
                
                Text(formatISO(file.createdAt))
                    .secondary()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    FileCardRedesign(PreviewProp.fileAttributes)
        .darkSchemePreferred()
}
