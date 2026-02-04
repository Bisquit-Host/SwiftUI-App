import SwiftUI

struct TopupProviderSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedProvider: PaymentProvider?
    let providers: [PaymentProvider]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(providers) { provider in
                    TopupProviderSheetRow(provider: provider, isSelected: provider == selectedProvider) {
                        selectedProvider = provider
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("Payment systems")
        .navigationBarTitleDisplayMode(.inline)
    }
}
