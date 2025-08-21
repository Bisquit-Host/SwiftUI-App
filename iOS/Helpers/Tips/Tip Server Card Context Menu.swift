import TipKit

struct TipServerCardContextMenu: Tip {
    var title: Text {
        Text("Context Menu")
    }
    
    var message: Text? {
        Text("Hold down the server card for a moment to access the context menu")
    }
    
    var image: Image? {
        Image(systemName: "contextualmenu.and.cursorarrow")
    }
}

#Preview {
    VStack {
        TipView(TipServerCardContextMenu())
            .tipBackground(.ultraThinMaterial)
            .padding()
    }
    .task {
        Tips.showAllTipsForTesting()
    }
#if !os(watchOS)
    .popoverTip(TipServerCardContextMenu())
#endif
}
