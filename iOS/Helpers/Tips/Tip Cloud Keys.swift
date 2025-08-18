import TipKit

struct Tip_CloudKeys: Tip {
    var title: Text {
        Text("Stored keys")
    }
    
    var message: Text? {
        Text("iCloud ensures the secure storage of your precious data, including API-keys")
    }
    
    var image: Image? {
        Image(systemName: "key.icloud")
    }
}

#Preview {
    VStack {
        TipView(Tip_CloudKeys())
            .tipBackground(.ultraThinMaterial)
            .padding()
    }
    .darkSchemePreferred()
#if !os(watchOS)
    .popoverTip(Tip_CloudKeys())
#endif
}
