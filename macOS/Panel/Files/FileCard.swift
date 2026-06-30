import ScrechKit
import Calagopus

struct FileCard: View {
    private let file: CalagopusFileEntry
    
    init(_ file: CalagopusFileEntry) {
        self.file = file
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(spacing: 5) {
                    FileIcon(file.mime)
                        .semibold()
                        .frame(width: 16)
                    
                    Text(file.name)
                        .lineLimit(3)
                }
            }
            
            Spacer()
            
            if file.file {
                let size = formatBytes(file.size)
                
                Text(size)
                    .footnote()
                    .secondary()
            }
        }
    }
}

#Preview {
    FileCard(PreviewProp.fileAttributes)
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
