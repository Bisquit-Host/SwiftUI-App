import ScrechKit
import Calagopus

struct FileNameAndIcon: View {
    private let file: CalagopusFileEntry
    
    init(_ file: CalagopusFileEntry) {
        self.file = file
    }
    
    private let spacing = 8.0
    
    var body: some View {
        HStack(spacing: spacing) {
            FileIcon(file.mime)
            
            Text(file.name)
        }
    }
}

#Preview {
    FileNameAndIcon(PreviewProp.fileAttributes)
        .darkSchemePreferred()
}
