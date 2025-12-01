import SwiftUI

struct TopupProviderCard: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    private let provider: PaymentProvider
    @Binding private var selectedProvider: PaymentProvider?
    
    init(_ provider: PaymentProvider, selectedProvider: Binding<PaymentProvider?>) {
        self.provider = provider
        _selectedProvider = selectedProvider
    }
    
    var body: some View {
        Button {
            selectedProvider = provider
        } label: {
            HStack(spacing: 8) {
                providerIcon
                
                Text(provider.name)
                    .subheadline(.semibold)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedProvider == provider ? provider.tint.opacity(0.12) : .primary.opacity(0.04))
            }
            .overlay {
                if differentiateWithoutColor && selectedProvider == provider {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.primary, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var providerIcon: some View {
        switch provider.icon {
        case .asset(let image):
            Image(image)
                .resizable()
                .frame(32)
                .clipShape(.rect(cornerRadius: 8))
            
        case .system(let name):
            Image(systemName: name)
                .font(.title3.weight(.semibold))
                .frame(width: 32, height: 32)
                .padding(6)
                .background(.primary.opacity(0.06), in: .rect(cornerRadius: 8))
        }
    }
}

//#Preview {
//    TopupProviderCard()
//}
