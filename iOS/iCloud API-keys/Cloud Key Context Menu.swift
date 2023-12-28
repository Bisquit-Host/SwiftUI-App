import ScrechKit

struct CloudKeyContextMenu: View {
    @Bindable private var key: APIKey
    @FocusState var focus: Bool
    
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
#endif
        
#if !os(tvOS)
        ShareLink(item: key.key, message: Text("API-key"))
#endif
    }
}
