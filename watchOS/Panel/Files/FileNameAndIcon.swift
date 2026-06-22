import ScrechKit
import Calagopus

struct FileNameAndIcon: View {
    private let file: CalagopusFileEntry
    
    init(_ file: CalagopusFileEntry) {
        self.file = file
    }
    
    private let spacing = System.isTV ? 16 : 8.0
    
    var body: some View {
        HStack(spacing: spacing) {
            FileIcon(file.mime)
            
            Text(file.name)
#if os(tvOS)
            Spacer()
            
            if !file.mime.contains("directory") {
                Text(formatBytes(file.size))
                    .secondary()
            }
#endif
        }
    }
}

#Preview {
    FileNameAndIcon(PreviewProp.fileAttributes)
        .darkSchemePreferred()
}
