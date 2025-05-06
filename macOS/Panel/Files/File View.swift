import ScrechKit
import PteroNet

struct FileView: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, root: String
    private let file: FileAttributes
    
    init(_ id: String, at root: String, file: FileAttributes) {
        self.id = id
        self.root = root
        self.file = file
    }
    
    var body: some View {
        NavigationLink {
            
        } label: {
            HStack {
                FileIcon(file.mimetype)
                    .semibold()
                    .frame(width: 20)
                
                Text(file.name)
            }
        }
        .buttonStyle(.plain)
        .padding(5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fileContextMenu(id, file: file, at: root)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
    }
}

#Preview {
    FileView("", at: "", file: sampleJSON(.fileListAttributes))
        .padding()
}
