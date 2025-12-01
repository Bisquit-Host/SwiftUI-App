import SwiftUI

struct TopupProviderCard: View {
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
                Image(provider.image)
                    .resizable()
                    .frame(32)
                    .clipShape(.rect(cornerRadius: 8))
                
                Text(provider.name)
                    .subheadline(.semibold)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedProvider == provider ? provider.tint.opacity(0.12) : .primary.opacity(0.04))
            }
        }
        .buttonStyle(.plain)
    }
}

//#Preview {
//    TopupProviderCard()
//}
