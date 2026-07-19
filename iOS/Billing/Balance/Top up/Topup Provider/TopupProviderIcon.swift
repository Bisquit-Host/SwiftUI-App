import SwiftUI

struct TopupProviderIcon: View {
    private let provider: PaymentProvider
    private let frame: CGFloat
    
    init(_ provider: PaymentProvider, frame: CGFloat = 32) {
        self.provider = provider
        self.frame = frame
    }
    
    var body: some View {
        switch provider.icon {
        case .asset(let image):
            Image(image)
                .resizable()
                .frame(frame)
                .clipShape(.rect(cornerRadius: 8))
            
        case .system(let name):
            Image(systemName: name)
                .title3(.semibold)
                .frame(frame)
                .padding(6)
                .background(.primary.opacity(0.06), in: .rect(cornerRadius: 8))
        }
    }
}
