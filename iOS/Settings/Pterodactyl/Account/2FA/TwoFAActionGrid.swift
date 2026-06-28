import ScrechKit

struct TwoFAActionGrid: View {
    private let qrCodeURL: String
    private let onShowQr: () -> Void
    
    init(_ qrCodeURL: String, onShowQr: @escaping () -> Void) {
        self.qrCodeURL = qrCodeURL
        self.onShowQr = onShowQr
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if let url = URL(string: qrCodeURL) {
                Link(destination: url) {
                    TwoFAActionTileContent("Open in authenticator", icon: "link.badge.plus")
                }
                .buttonStyle(.plain)
                
                ShareLink(item: url) {
                    TwoFAActionTileContent("Share setup URL", icon: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
            }
            
            TwoFAActionTile("View QR code", icon: "qrcode") {
                onShowQr()
            }
        }
    }
}
