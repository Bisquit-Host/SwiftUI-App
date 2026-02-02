import SwiftUI
import OSLog

struct QRCodeView: View {
    private let url: String?
    
    init(_ url: String?) {
        self.url = url
    }
    
    @State private var image: UIImage?
    
    var body: some View {
        VStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 5))
                    .padding()
            }
        }
        .presentationDetents([.medium])
        .task {
            if let url {
                image = generateQRCode(url)
            }
        }
    }
    
    private func generateQRCode(_ url: String) -> UIImage? {
        Logger().info("Generating QR code for: \(url)")
        
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        let data = url.data(using: .utf8)
        
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel") // High correction level
        
        guard let qrImage = qrFilter.outputImage else {
            Logger().error("qrImage couldn't be created")
            return nil
        }
        
        // Scaling QR code image
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQRImage = qrImage.transformed(by: transform)
        
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(scaledQRImage, from: scaledQRImage.extent) else {
            Logger().error("QR code couldn't be converted to cgImage")
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    //    private func generateQRCode() -> UIImage {
    //        let context = CIContext()
    //        let filter = CIFilter.qrCodeGenerator()
    //
    //        let data = Data(url?.utf8 ?? "".utf8)
    //        filter.setValue(data, forKey: "inputMessage")
    //
    //        if let outputImage = filter.outputImage {
    //            // Scales the image by 10 times in both directions
    //            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
    //
    //            if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
    //                return UIImage(cgImage: cgImage)
    //            }
    //        }
    //
    //        return UIImage(systemName: "xmark.circle") ?? UIImage()
    //    }
}

#Preview {
    QRCodeView(Endpoint.bisquitHost)
        .darkSchemePreferred()
}
