import SwiftUI

struct TopupProviderCard: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    let provider: PaymentProvider
    @Binding var selectedProvider: PaymentProvider?
    
    private var avgColor: Color {
        switch provider.icon {
            
        case .asset(let resource):
            Color(uiColor: UIImage(resource: resource).findAverageColor() ?? .blue)
            
        default: .blue
        }
    }
    
    var body: some View {
        Button {
            withAnimation {
                selectedProvider = provider
            }
        } label: {
            HStack(spacing: 8) {
                TopupProviderIcon(provider)
                
                Text(provider.name)
                    .subheadline(.semibold)
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
}

//#Preview {
//    TopupProviderCard()
//}
