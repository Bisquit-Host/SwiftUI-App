import ScrechKit

struct TwoFAActionGrid: View {
    let qrCodeURL: String
    var onShowQr: () -> Void
    
    init(_ qrCodeURL: String, onShowQr: @escaping () -> Void) {
        self.qrCodeURL = qrCodeURL
        self.onShowQr = onShowQr
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if let url = URL(string: qrCodeURL) {
                Link(destination: url) {
                    TwoFAActionTileContent("Open in authenticator", subtitle: "Launches your 2FA app", icon: "link.badge.plus")
                }
                .buttonStyle(.plain)
                
                ShareLink(item: url) {
                    TwoFAActionTileContent("Share setup URL", subtitle: "Send via AirDrop or chat", icon: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
            }
            
            TwoFAActionTile("View QR code", subtitle: "Scan directly from your screen", icon: "qrcode") {
                onShowQr()
            }
        }
    }
}
