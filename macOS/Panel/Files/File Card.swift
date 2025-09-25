import ScrechKit
import PteroNet

struct FileCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let file: FileAttributes
    
    init(_ file: FileAttributes) {
        self.file = file
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(spacing: 5) {
                    FileIcon(file.mimetype)
                        .semibold()
                        .frame(width: 16)
                    
                    Text(file.name)
                        .lineLimit(3)
                }
                
                if store.devMode {
                    Text(file.mimetype)
                        .footnote()
                        .secondary()
                }
            }
            
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

#Preview {
    FileCard(PreviewProp.fileAttributes)
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
