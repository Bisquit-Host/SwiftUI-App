import SwiftUI
import PteroNet

struct FilePermissionsParent: View {
    private let file: FileAttributes
    private let root: String
    
    init(_ file: FileAttributes, at root: String) {
        self.file = file
        self.root = root
    }
    
    var body: some View {
#if os(watchOS) || os(macOS)
        FilePermissionsView(file, at: root)
#else
        NavigationView {
            FilePermissionsView(file, at: root)
        }
#endif
    }
}
