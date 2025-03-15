import SwiftUI

struct IconSettings: View {
    var body: some View {
        Section("Icon") {
            AppIconPicker()
        }
        .transparentSection()
    }
}

#Preview {
    List {
        IconSettings()
    }
    .environmentObject(ValueStore())
}
