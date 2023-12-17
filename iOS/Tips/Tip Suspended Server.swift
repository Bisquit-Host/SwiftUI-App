import TipKit

struct Tip_SuspendedServer: Tip {
    var title: Text {
        Text("Suspended Server")
    }
    
    var message: Text? {
        Text("Tip.SuspendedServer")
    }
    
    var image: Image? {
        Image(systemName: "snow")
    }
}

#Preview {
    VStack {
        TipView(Tip_SuspendedServer())
    }
#if os(iOS)
    .popoverTip(Tip_SuspendedServer())
#endif
}
