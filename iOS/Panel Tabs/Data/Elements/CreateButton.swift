import SwiftUI

struct CreateButton: View {
    private let name: LocalizedStringResource
    private let disabled: Bool
    private let action: () -> Void
    
    init(_ name: LocalizedStringResource, disabled: Bool, action: @escaping () -> Void) {
        self.name = name
        self.disabled = disabled
        self.action = action
    }
    
    var body: some View {
        Button("\(name)") {
            action()
        }
        .bold()
        .foregroundStyle(.white)
        .padding(.vertical, 10)
        .lineLimit(1)
        .minimumScaleFactor(0.25)
        .padding(.horizontal, 5)
        .multilineTextAlignment(.center)
        .disabled(disabled)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.blue, in: .rect(cornerRadius: 16))
        .padding(.vertical, 10)
    }
}
