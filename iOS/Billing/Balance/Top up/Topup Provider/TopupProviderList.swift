import SwiftUI

struct TopupProviderList: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var store: ValueStore
    @Binding private var selectedProvider: PaymentProvider?
    private let providers: [PaymentProvider]
    
    init(_ selectedProvider: Binding<PaymentProvider?>, providers: [PaymentProvider]) {
        _selectedProvider = selectedProvider
        self.providers = providers
    }
    
    @State private var isSheetPresented = false
    
    var body: some View {
        Button {
            isSheetPresented = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    if let selectedProvider {
                        TopupProviderIcon(selectedProvider)
                            .id(selectedProvider.iconTransitionID)
                            .transition(
                                reduceMotion || !store.bigAssAnimations
                                ? .opacity
                                : .asymmetric(
                                    insertion: .scale(scale: 0.85).combined(with: .opacity),
                                    removal: .scale(scale: 1.1).combined(with: .opacity)
                                )
                            )
                    } else {
                        Image(systemName: "creditcard")
                            .title3(.semibold)
                            .frame(32)
                            .padding(6)
                            .background(.primary.opacity(0.06), in: .rect(cornerRadius: 8))
                            .id("system-creditcard")
                            .transition(
                                reduceMotion || !store.bigAssAnimations
                                ? .opacity
                                : .asymmetric(
                                    insertion: .scale(scale: 0.85).combined(with: .opacity),
                                    removal: .scale(scale: 1.1).combined(with: .opacity)
                                )
                            )
                    }
                }
                .frame(44)
                .animation(
                    reduceMotion || !store.bigAssAnimations
                    ? nil
                    : .snappy(duration: 0.25, extraBounce: 0.12),
                    value: selectedProvider?.iconTransitionID ?? "system-creditcard"
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Payment provider")
                        .footnote()
                        .secondary()
                    
                    Text(selectedProvider?.name ?? "Select payment system")
                        .subheadline(.semibold)
                        .numericTransition()
                        .animation(.default, value: selectedProvider?.name)
                }
                
                Spacer()
                
                if let selectedProvider {
                    Text(selectedProvider.currency.displaySymbol)
                        .subheadline(.semibold)
                        .secondary()
                        .numericTransition()
                        .animation(.default, value: selectedProvider.currency.displaySymbol)
                }
                
                Image(systemName: "chevron.up.chevron.down")
                    .footnote()
                    .secondary()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.primary.opacity(0.05), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(providers.isEmpty)
        .opacity(providers.isEmpty ? 0.6 : 1)
        .sheet($isSheetPresented) {
            NavigationStack {
                TopupProviderSheet(selectedProvider: $selectedProvider, providers: providers)
            }
            .presentationDetents([.fraction(0.5)])
            .presentationDragIndicator(.visible)
        }
    }
}

//#Preview {
//    TopupProviderList()
//        .darkSchemePreferred()
//}
