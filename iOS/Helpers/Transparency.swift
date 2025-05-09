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

struct TransparentSection: ViewModifier {
    @EnvironmentObject private var store: ValueStore
    
    func body(content: Content) -> some View {
#if !os(iOS)
        content
#else
        if store.transparentList {
            content
                .listRowBackground(Color.clear)
        } else {
            content
        }
#endif
    }
}

extension View {
    func transparentList() -> some View {
        modifier(TransparentList())
    }
    
    func transparentSection() -> some View {
        modifier(TransparentSection())
    }
}

struct DismissButton: View {
    var dismiss: () -> Void
    
    var body: some View {
        // Do not use SFButton()
        
        Button(action: dismiss) {
            Image(systemName: "xmark")
                .footnote(.bold)
                .frame(35)
                .background(.ultraThinMaterial, in: .circle)
                .foregroundStyle(.foreground)
        }
    }
}
