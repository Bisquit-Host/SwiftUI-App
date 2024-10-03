import ScrechKit

struct CloudKeyContextMenu: View {
    @Bindable private var key: APIKey
    @Binding private var alertRename: Bool
    
    init(_ alertRename: Binding<Bool>, key: APIKey) {
        self.key = key
        _alertRename = alertRename
    }
    
    var body: some View {
        MenuButton("Rename", icon: "pencil") {
            alertRename = true
        }
        
#if !os(tvOS)
        MenuButton("Copy", icon: "doc.on.doc") {
            UIPasteboard.general.string = key.key
            SystemAlert.copied()
        }
        
        ShareLink(item: key.key, message: Text("API-key"))
#endif
        
        Section {
            MenuButton("Delete", role: .destructive, icon: "trash") {
                key.modelContext?.delete(key)
            }
        }
    }
}
