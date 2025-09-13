import SwiftUI
import PteroNet

struct FileListRedesign: View {
    private let files: [FileAttributes] = [
        .init(
            name: "Document.txt",
            size: 2048,
            isFile: true,
            isSymlink: false,
            mimetype: "text/plain",
            mode: "rw-r--r--",
            modeBits: "0644",
            createdAt: "2025-01-01T12:00:00Z",
            modifiedAt: "2025-01-02T09:30:00Z"
        ),
        .init(
            name: "Image.png",
            size: 502344,
            isFile: true,
            isSymlink: false,
            mimetype: "image/png",
            mode: "rw-r--r--",
            modeBits: "0644",
            createdAt: "2025-02-15T10:45:00Z",
            modifiedAt: "2025-02-15T11:00:00Z"
        ),
        .init(
            name: "Shortcut",
            size: 0,
            isFile: false,
            isSymlink: true,
            mimetype: "inode/symlink",
            mode: "lrwxr-xr-x",
            modeBits: "0777",
            createdAt: "2025-03-01T08:15:00Z",
            modifiedAt: "2025-03-01T08:15:00Z"
        ),
        .init(
            name: "Archive.zip",
            size: 12034890,
            isFile: true,
            isSymlink: false,
            mimetype: "application/zip",
            mode: "rw-r--r--",
            modeBits: "0644",
            createdAt: "2025-04-10T14:20:00Z",
            modifiedAt: "2025-04-11T09:00:00Z"
        )
    ]
    
    var body: some View {
        ForEach(files) {
            FileCardRedesign($0)
        }
    }
}

#Preview {
    FileListRedesign()
}
