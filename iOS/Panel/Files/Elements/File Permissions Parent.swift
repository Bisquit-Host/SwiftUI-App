import SwiftUI
import PteroNet

struct FilePermissionsParent: View {
    private let file: FileAttributes
    private let root: String
    
    init(_ file: FileAttributes, root: String) {
        self.file = file
        self.root = root
    }
    
    var body: some View {
#if os(watchOS)
        FilePermissionsView(file, root: root)
#else
        NavigationView {
            FilePermissionsView(file, root: root)
        }
#endif
    }
}
