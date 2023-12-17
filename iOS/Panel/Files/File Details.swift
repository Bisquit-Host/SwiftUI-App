import ScrechKit
import PteroNet

struct FileDetails: View {
    private let file: FileListAttributes
    
    var body: some View {
        VStack(alignment: .leading) {
            if file.is_file {
                Text("Size: \(formatBytes(file.size))")
            }
            
            Text("Modified: \(file.modified_at)")
            
            Text("Created: \(file.created_at)")
        }
        .footnote()
    }
}
