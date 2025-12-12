import SwiftUI

struct VDSPowerButton: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    private let title: LocalizedStringKey
    private let symbol: String
    private let tint: Color
    private let action: () async -> Void
    
    init(_ title: LocalizedStringKey, symbol: String, tint: Color, action: @escaping () async -> Void) {
        self.title = title
        self.symbol = symbol
        self.tint = tint
        self.action = action
    }
    
    var body: some View {
        Button {
            Task { await action() }
        } label: {
            HStack {
                Image(systemName: symbol)
                Text(title)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(tint.opacity(0.12), in: .capsule)
        }
        .buttonStyle(.plain)
        .disabled(vm.isPerformingAction)
    }
}
