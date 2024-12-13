import ScrechKit
import PteroNet

struct FileNameAndIcon: View {
    private let file: FileAttributes
    
    init(_ file: FileAttributes) {
        self.file = file
    }
    
#if os(tvOS)
    private let spacing = 16.0
#elseif os(watchOS)
    private let spacing = 8.0
#endif
    
    var body: some View {
        HStack(spacing: spacing) {
            FileIcon(file.mimetype)
            
            Text(file.name)
#if os(tvOS)
            Spacer()
            
            if !file.mimetype.contains("directory") {
                Text(formatBytes(file.size))
                    .secondary()
            }
#endif
        }
    }
}

#Preview {
    FileNameAndIcon(sampleJSON(.fileListAttributes))
}
