import ScrechKit

struct TwoFAActionGrid: View {
    let qrCodeURL: String
    var onShowQr: () -> Void
    
    private var setupUrl: URL? {
        URL(string: qrCodeURL)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if let setupUrl {
                Link(destination: setupUrl) {
                    TwoFAActionTileContent("Open in authenticator", subtitle: "Launches your 2FA app", icon: "link.badge.plus")
                }
                .buttonStyle(.plain)
                
                ShareLink(item: setupUrl) {
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
