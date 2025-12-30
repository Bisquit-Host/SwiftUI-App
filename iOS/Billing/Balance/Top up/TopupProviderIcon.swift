import SwiftUI

struct TopupProviderIcon: View {
    private let provider: PaymentProvider
    
    init(_ provider: PaymentProvider) {
        self.provider = provider
    }
    
    var body: some View {
        switch provider.icon {
        case .asset(let image):
            Image(image)
                .resizable()
                .frame(32)
                .clipShape(.rect(cornerRadius: 8))
            
        case .system(let name):
            Image(systemName: name)
                .title3(.semibold)
                .frame(32)
                .padding(6)
                .background(.primary.opacity(0.06), in: .rect(cornerRadius: 8))
        }
    }
}
