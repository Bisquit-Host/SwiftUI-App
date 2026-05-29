import TipKit

struct TipUnusedAPIKeys: Tip {
    var title: Text {
        Text("Unused API keys")
    }
    
    var message: Text? {
        Text("You have API keys that are no longer in use")
    }
    
    var image: Image? {
        Image(systemName: "key.viewfinder")
    }
    
    var actions: [Action] {
        Action(id: "view", title: "View")
    }
}

#Preview {
    VStack {
        TipView(TipUnusedAPIKeys())
            .tipBackground(.ultraThinMaterial)
            .padding()
    }
    .darkSchemePreferred()
#if !os(watchOS)
    .popoverTip(TipUnusedAPIKeys())
#endif
}
