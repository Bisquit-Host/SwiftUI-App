import SwiftUI

struct BillingToggleRow: View {
    private let title: LocalizedStringKey
    private let icon: String
    private let tint: Color
    @Binding private var isOn: Bool
    
    init(_ title: LocalizedStringKey, icon: String, tint: Color, isOn: Binding<Bool>) {
        self.title = title
        self.icon = icon
        self.tint = tint
        _isOn = isOn
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(32)
                .glassEffect(.regular.tint(tint.opacity(0.15)), in: .rect(cornerRadius: 10))
                .foregroundStyle(tint)
            
            Text(title)
                .subheadline(.semibold)
            
            Spacer()
            
            Toggle(isOn: $isOn) {
                EmptyView()
            }
            .labelsHidden()
            .tint(tint)
        }
    }
}
