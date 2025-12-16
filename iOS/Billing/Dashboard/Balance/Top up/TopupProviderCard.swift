import SwiftUI

struct TopupProviderCard: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    @Binding private var selectedProvider: PaymentProvider?
    private let provider: PaymentProvider
    
    init(_ selectedProvider: Binding<PaymentProvider?>, provider: PaymentProvider) {
        _selectedProvider = selectedProvider
        self.provider = provider
    }
    
    private var avgColor: Color {
        switch provider.icon {
        case .asset(let resource): Color(uiColor: UIImage(resource: resource).findAverageColor() ?? .blue)
        default: .blue
        }
    }
    
    var body: some View {
        Button(action: select) {
            HStack(spacing: 8) {
                TopupProviderIcon(provider)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(provider.name)
                        .subheadline(.semibold)
                    
                    Text(provider.currency.rawValue)
                        .footnote()
                        .secondary()
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedProvider == provider ? avgColor.opacity(0.5) : .primary.opacity(0.04))
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
    
    private func select() {
        withAnimation {
            selectedProvider = provider
        }
    }
}

//#Preview {
//    TopupProviderCard()
//}
