import TipKit

struct Tip_ServerCardContextMenu: Tip {
    var title: Text {
        Text("Context Menu")
    }
    
    var message: Text? {
        Text("Hold down the server card for a moment to access the context menu.")
    }
    
    var image: Image? {
        Image(systemName: "contextualmenu.and.cursorarrow")
    }
}

#Preview {
    VStack {
        TipView(Tip_ServerCardContextMenu())
            .padding()
    }
    .task {
        try? Tips.showAllTipsForTesting()
    }
#if !os(watchOS)
    .popoverTip(Tip_ServerCardContextMenu())
#endif
}
