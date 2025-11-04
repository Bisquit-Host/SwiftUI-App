import SwiftUI
import TipKit

struct DebugSettingsTips: View {
    var body: some View {
        Section {
            Button {
                Tips.showAllTipsForTesting()
            } label: {
                Label {
                    Text("Show all tips")
                } icon: {
                    Image(systemName: "lightbulb.max")
                        .foregroundStyle(.yellow)
                }
            }
        }
    }
}

#Preview {
    List {
        DebugSettingsTips()
    }
    .darkSchemePreferred()
    .foregroundStyle(.foreground)
}
