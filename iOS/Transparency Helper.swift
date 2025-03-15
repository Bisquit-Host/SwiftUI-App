import SwiftUI

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
        content
#if os(iOS)
            .listRowBackground(store.transparentList ? .clear : Color.list)
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
