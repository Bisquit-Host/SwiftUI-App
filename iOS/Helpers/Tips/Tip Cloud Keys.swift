import TipKit

struct TipCloudKeys: Tip {
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
        TipView(TipCloudKeys())
            .tipBackground(.ultraThinMaterial)
            .padding()
    }
#if !os(watchOS)
    .popoverTip(TipCloudKeys())
#endif
}
