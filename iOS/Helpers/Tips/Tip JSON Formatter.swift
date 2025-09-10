import TipKit

struct TipJsonFormatter: Tip {
    var title: Text {
        Text("JSON Formatter")
    }
    
    var message: Text? {
        Text("Easily format and visualize your JSON data")
    }
    
    var image: Image? {
        Image(systemName: "ellipsis.curlybraces")
    }
    
    var actions: [Action] {
        Action(id: "format-json", title: "Format")
    }
}

#Preview {
    VStack {
        TipView(TipJsonFormatter())
            .tipBackground(.ultraThinMaterial)
            .padding()
    }
#if !os(watchOS)
    .popoverTip(TipJsonFormatter())
#endif
}
