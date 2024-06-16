import ScrechKit
import PteroNet

#warning("Unused")

struct FileDetails: View {
    private let file: FileAttributes
    
    init(_ file: FileAttributes) {
        self.file = file
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if file.isFile {
                Text("Size: \(formatBytes(file.size))")
            }
            
            Text("Modified: \(file.modifiedAt)")
            
            Text("Created: \(file.createdAt)")
        }
        .footnote()
    }
}
