import ScrechKit

struct UpgradePackage: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(DashboardVM.self) private var dashboardVM
    
    let pkg: ChangeablePackage
    @Binding var selectedUpgradeId: Int?
    
    private var isSelected: Bool {
        selectedUpgradeId == pkg.id
    }
    
    var body: some View {
        Button(action: select) {
            let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout())
            
            layout {
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        if differentiateWithoutColor && isSelected {
                            Image(systemName: "checkmark")
                                .accessibilityHidden(true)
                        }

                        Text(pkg.name)
                    }
                    .headline()
                    .foregroundStyle(.primary)
                    
                    Text("\(monthlyPrice)/mo")
                        .subheadline()
                        .secondary()
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Text("Pay now")
                    
                    Text(priceNow)
                        .monospacedDigit()
                }
                .subheadline()
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.primary.opacity(0.1), in: .capsule)
                .fixedSize(horizontal: !dynamicTypeSize.isAccessibilitySize, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.accentColor.opacity(0.06) : .clear, in: .rect(cornerRadius: isSelected ? 15 : 14))
            .overlay {
                RoundedRectangle(cornerRadius: isSelected ? 15 : 14)
                    .stroke(
                        isSelected ? Color.accentColor : .primary.opacity(0.12),
                        lineWidth: differentiateWithoutColor && isSelected ? 2 : 1
                    )
            }
            .contentShape(.rect(cornerRadius: isSelected ? 15 : 14))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    private func select() {
        selectedUpgradeId = pkg.id
    }
    
    private var priceNow: String {
        formatCurrency(pkg.amountDueNow, user: dashboardVM.user)
    }
    
    private var monthlyPrice: String {
        formatCurrency(pkg.price, user: dashboardVM.user)
    }
    
}

#Preview {
    @Previewable @State var selectedUpgradeId: Int? = nil
    
    BillingSectionCard("Change plan") {
        UpgradePackage(pkg: .preview, selectedUpgradeId: $selectedUpgradeId)
    }
    .environment(DashboardVM())
    .darkSchemePreferred()
}
