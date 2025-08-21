import SwiftUI
import CoreGraphics

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
                    .clipShape(.rect(cornerRadius: 16))
                    .padding()
                //                    .contextMenu {
                //
                //                    }
            }
        }
        .task {
            if let url {
                image = generateQRCode(url)
            }
        }
        .presentationDetents([.medium])
    }
    
    private func generateQRCode(_ url: String) -> UIImage? {
        let data = url.data(using: .utf8)
        
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel") // High correction level
        
        guard let qrImage = qrFilter.outputImage else {
            return nil
        }
        
        // Scaling the QR code image
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQRImage = qrImage.transformed(by: transform)
        
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(scaledQRImage, from: scaledQRImage.extent) else {
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
    //            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10)) // Scales the image by 10 times in both directions
    //            if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
    //                return UIImage(cgImage: cgImage)
    //            }
    //        }
    //
    //        return UIImage(systemName: "xmark.circle") ?? UIImage()
    //    }
}

#Preview {
    QRCodeView("https://bisquit.host")
}
