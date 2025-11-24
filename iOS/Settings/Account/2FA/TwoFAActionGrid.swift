import ScrechKit

struct TwoFAActionGrid: View {
    let qrCodeUrl: String
    var onShowQr: () -> Void
    
    private var setupUrl: URL? {
        URL(string: qrCodeUrl)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            TwoFAActionTile("Copy setup URL", subtitle: "Paste into another device", icon: "doc.on.doc") {
                Pasteboard.copy(qrCodeUrl)
                SystemAlert.copied()
            }
            
            if let url = setupUrl {
                Link(destination: url) {
                    TwoFAActionTileContent(
                        "Open setup URL",
                        subtitle: "Opens in browser",
                        icon: "globe"
                    )
                }
                .buttonStyle(.plain)
                
                Link(destination: url) {
                    TwoFAActionTileContent(
                        "Open in authenticator",
                        subtitle: "Launches your 2FA app",
                        icon: "link.badge.plus"
                    )
                }
                .buttonStyle(.plain)
                
                ShareLink(item: url) {
                    TwoFAActionTileContent(
                        "Share setup",
                        subtitle: "Send via AirDrop or chat",
                        icon: "square.and.arrow.up"
                    )
                }
                .buttonStyle(.plain)
            }
            
            TwoFAActionTile("View QR code", subtitle: "Scan directly from your screen", icon: "qrcode") {
                onShowQr()
            }
        }
    }
}
