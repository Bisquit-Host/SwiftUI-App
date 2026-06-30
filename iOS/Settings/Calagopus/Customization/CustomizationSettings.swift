import SwiftUI

struct CustomizationSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        BillingSectionCard("Customization") {
            ServerCardLayoutButton()
            BackgroundImageButton()
        }
    }
}

#Preview {
    List {
        CustomizationSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
