import TipKit

struct Tip_CloudKeys: Tip {
    var title: Text {
        Text("Stored keys")
    }
    
    var message: Text? {
        Text("Info.CloudStorage")
    }
    
    var image: Image? {
        Image(systemName: "key.icloud")
    }
}

#Preview {
    VStack {
        TipView(Tip_CloudKeys())
    }
#if os(iOS)
    .popoverTip(Tip_CloudKeys())
#endif
}
