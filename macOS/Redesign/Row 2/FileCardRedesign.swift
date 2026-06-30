import ScrechKit
import Calagopus

struct FileCardRedesign: View {
    private let file: CalagopusFileEntry
    
    init(_ file: CalagopusFileEntry) {
        self.file = file
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Group {
                HStack {
                    FileIcon(file.mime)
                    
                    Text(file.name)
                        .lineLimit(2)
                }
                
                Text(formatBytes(file.size))
                    .secondary()
                
                Text(formatISO(file.created))
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
