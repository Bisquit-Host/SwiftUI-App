import SwiftUI

struct CustomizationSettings: View {
    var body: some View {
        BillingSectionCard("Customization") {
            ServerCardLayoutButton()
        }
    }
}

#Preview {
    List {
        CustomizationSettings()
    }
    .darkSchemePreferred()
}
