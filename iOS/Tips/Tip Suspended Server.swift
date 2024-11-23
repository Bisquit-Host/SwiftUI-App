import TipKit

struct Tip_SuspendedServer: Tip {
    var title: Text {
        Text("Suspended Server")
    }
    
    var message: Text? {
        Text("Data may be lost if the service is not renewed")
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
