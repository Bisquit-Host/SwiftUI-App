import TipKit

struct TipEnable2FA: Tip {
    var title: Text {
        Text("Enable 2FA")
    }
    
    var message: Text? {
        Text("Turn on two-factor authentication to protect your account")
    }
    
    var image: Image? {
        Image(systemName: "shield.lefthalf.fill")
    }
}

#Preview {
    TipView(TipEnable2FA())
        .padding()
        .darkSchemePreferred()
}
