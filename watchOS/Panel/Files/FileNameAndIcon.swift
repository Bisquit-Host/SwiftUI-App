import ScrechKit
import PteroNet

struct FileNameAndIcon: View {
    private let file: FileAttributes
    
    init(_ file: FileAttributes) {
        self.file = file
    }
#if os(tvOS)
    private let spacing: CGFloat = 16
#elseif os(watchOS)
    private let spacing: CGFloat = 8
#endif
    
    var body: some View {
        HStack(spacing: spacing) {
            FileIconView(file.mimetype)
            
            Text(file.name)
#if os(tvOS)
            Spacer()
            
            if !file.mimetype.contains("directory") {
                Text(formatBytes(file.size))
                    .foregroundStyle(.secondary)
            }
#endif
        }
    }
}

#Preview {
    FileNameAndIcon(
        sampleJSON(.fileListAttributes)
    )
}
