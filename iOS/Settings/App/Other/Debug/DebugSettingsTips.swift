import SwiftUI
import TipKit

struct DebugSettingsTips: View {
    @State private var trigger = false
    
    var body: some View {
        Section {
            Button(action: shpwAllTips) {
                Label {
                    Text("Show all tips")
                } icon: {
                    Image(systemName: "lightbulb.max")
                        .foregroundStyle(.yellow)
                }
            }
            .hapticOn(trigger, as: .success)
        }
    }
    
    private func shpwAllTips() {
        Tips.showAllTipsForTesting()
        trigger.toggle()
    }
}

#Preview {
    List {
        DebugSettingsTips()
    }
    .darkSchemePreferred()
    .foregroundStyle(.foreground)
}
