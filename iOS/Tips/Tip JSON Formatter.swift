import TipKit

struct Tip_JsonFormatter: Tip {
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
        TipView(Tip_JsonFormatter())
    }
#if !os(watchOS)
    .popoverTip(Tip_JsonFormatter())
#endif
}
