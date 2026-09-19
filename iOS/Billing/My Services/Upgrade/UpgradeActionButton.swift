import SwiftUI

struct UpgradeActionButton: View {
    @ScaledMetric private var extraVerticalPadding = 14

    let planName: String?
    let isPerformingAction: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Group {
                if isPerformingAction {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Group {
                        if let planName {
                            Text("Change plan to \(planName)")
                        } else {
                            Text("Change plan")
                        }
                    }
                    .semibold()
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, extraVerticalPadding)
        }
        .buttonStyle(.borderedProminent)
        .disabled(isDisabled)
    }
}
