import ScrechKit

struct CloudKeyContextMenu: View {
    @Bindable private var key: APIKey
    @FocusState private var focus
    
    init(_ key: APIKey, focus: FocusState<Bool>) {
        self.key = key
        _focus = focus
    }
    
    var body: some View {
        MenuButton("Rename", icon: "pencil") {
            focus = true
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
