import ScrechKit
import PteroNet

struct FileDetails: View {
    private let file: FileAttributes
    
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
