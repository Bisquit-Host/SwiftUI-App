import SwiftUI

struct UpgradeActionButton: View {
    let title: String
    let subtitle: String?
    let isPerformingAction: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if isPerformingAction {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 2) {
                    Text(title)
                        .semibold()
                    
                    if let subtitle {
                        Text(subtitle)
                            .footnote()
                            .secondary()
                            .monospacedDigit()
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(isDisabled)
    }
}
