import SwiftUI
import BisquitoNet

struct Billing2FASetupContentQRCode: View {
    private let setup: Billing2FASetupResponse
    
    init(_ setup: Billing2FASetupResponse) {
        self.setup = setup
    }
    
    @State private var isBlurred = true
    
    var body: some View {
        if let qr = generateQRCode(setup.url) {
            Button(action: toggleBlur) {
                Image(uiImage: qr)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 240)
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(32)
                    .blur(radius: isBlurred ? 8 : 0)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isBlurred ? "Reveal QR code" : "Hide QR code")
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    private func toggleBlur() {
        isBlurred.toggle()
    }
    
    private func generateQRCode(_ text: String) -> UIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        let data = text.data(using: .utf8)
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        guard let qrImage = qrFilter.outputImage else {
            return nil
        }
        
        let transform = CGAffineTransform(scaleX: 8, y: 8)
        let scaledQRImage = qrImage.transformed(by: transform)
        
        guard let cgImage = CIContext().createCGImage(scaledQRImage, from: scaledQRImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

//#Preview {
//    Billing2FASetupContentQRCode()
//        .darkSchemePreferred()
//}
