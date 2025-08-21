import TipKit

struct TipSuspendedServer: Tip {
    var title: Text {
        Text("Suspended Server")
    }
    
    var message: Text? {
        Text("Data may be lost if the service is not renewed")
    }
    
    var image: Image? {
        Image(systemName: "snow")
    }
    
    var actions: [Action] {
        Action(id: "open-billing", title: "Billing")
    }
}

#Preview {
    VStack {
        TipView(TipSuspendedServer())
            .tipBackground(.ultraThinMaterial)
            .padding()
    }
#if !os(watchOS)
    .popoverTip(TipSuspendedServer())
#endif
}
