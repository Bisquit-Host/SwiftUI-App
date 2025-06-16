import ScrechKit

struct TransparentList: ViewModifier {
    @EnvironmentObject private var store: ValueStore
    
    func body(content: Content) -> some View {
        content
#if os(iOS)
            .scrollContentBackground(store.transparentSheet ? .hidden : .visible)
            .presentationBackground(store.transparentSheet ? .ultraThinMaterial : .regular)
#endif
    }
}

extension View {
    func transparentList() -> some View {
        modifier(TransparentList())
    }
}

#warning("Remove?")
struct DismissButton: View {
    var dismiss: () -> Void
    
    var body: some View {
        // Do not use SFButton()
        
        Button(action: dismiss) {
            Image(systemName: "xmark")
        }
    }
}
