import SwiftUI

struct PluginPolymartSection: View {
    let isLoadingPolymart: Bool
    let isPolymartLinked: Bool
    let handlePolymartAction: () -> Void
    
    var body: some View {
        BillingSectionCard("Polymart account", showsBackground: false) {
            VStack(alignment: .leading, spacing: 12) {
                if isLoadingPolymart {
                    HStack(spacing: 10) {
                        ProgressView()
                        
                        Text("Loading account state")
                            .secondary()
                    }
                } else {
                    Text(isPolymartLinked ? "Connected" : "Not connected")
                        .subheadline(.semibold)
                    
                    Button {
                        handlePolymartAction()
                    } label: {
                        Label(
                            isPolymartLinked ? "Disconnect Polymart" : "Connect Polymart",
                            systemImage: isPolymartLinked ? "link.badge.minus" : "link.badge.plus"
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isPolymartLinked ? .red : .blue)
                }
            }
        }
    }
}
