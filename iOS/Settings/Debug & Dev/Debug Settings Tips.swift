import SwiftUI
import TipKit

struct DebugSettingsTips: View {
    var body: some View {
        Section {
            Button {
                Tips.showAllTipsForTesting()
            } label: {
                Label("Show all tips", systemImage: "lightbulb.max")
                    .foregroundStyle(.yellow)
            }
        }
        .transparentSection()
    }
}

#Preview {
    DebugSettingsTips()
}
