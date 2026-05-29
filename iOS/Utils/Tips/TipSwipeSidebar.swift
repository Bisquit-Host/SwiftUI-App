import TipKit

struct TipSwipeSidebar: Tip {
    var title: Text {
        Text("Sidebar navigation")
    }
    
    var message: Text? {
        Text("Swipe from the middle to open the sidebar")
    }
    
    var image: Image? {
        Image(systemName: "sidebar.left")
    }
}

#Preview {
    VStack {
        TipView(TipSwipeSidebar())
            .tipBackground(.ultraThinMaterial)
            .padding()
    }
    .darkSchemePreferred()
#if !os(watchOS)
    .popoverTip(TipSwipeSidebar())
#endif
}
