import SwiftUI
import Calagopus

struct FilePermissionsParent: View {
    private let file: CalagopusFileEntry
    private let root: String
    
    init(_ file: CalagopusFileEntry, at root: String) {
        self.file = file
        self.root = root
    }
    
    var body: some View {
#if os(watchOS) || os(macOS)
        FilePermissionsView(file, at: root)
#else
        NavigationStack {
            FilePermissionsView(file, at: root)
        }
#endif
    }
}
