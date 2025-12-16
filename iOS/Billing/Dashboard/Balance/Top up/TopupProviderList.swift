import SwiftUI

struct TopupProviderList: View {
    @Binding private var selectedProvider: PaymentProvider?
    private let providers: [PaymentProvider]
    
    init(_ selectedProvider: Binding<PaymentProvider?>, providers: [PaymentProvider]) {
        _selectedProvider = selectedProvider
        self.providers = providers
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(providers) {
                    TopupProviderCard(provider: $0, selectedProvider: $selectedProvider)
                }
            }
        }
        .scrollIndicators(.never)
    }
}

//#Preview {
//    TopupProviderList()
//        .darkSchemePreferred()
//}
