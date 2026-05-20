import ScrechKit

struct CloudKeyContextMenu: View {
    @Bindable private var key: APIKey
    @Binding private var alertRename: Bool
    
    init(_ alertRename: Binding<Bool>, key: APIKey) {
        self.key = key
        _alertRename = alertRename
    }
    
    var body: some View {
        Button("Rename", systemImage: "pencil") {
            alertRename = true
        }
        
#if !os(tvOS)
        Button("Copy", systemImage: "doc.on.doc") {
            Pasteboard.copy(key.key)
            SystemAlert.copied()
        }
        
        ShareLink(item: key.key, message: Text("API key"))
#endif
        
        Section {
            Button("Delete", systemImage: "trash", role: .destructive) {
                key.modelContext?.delete(key)
            }
        }
    }
}
