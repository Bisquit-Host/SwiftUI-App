import SwiftUI

struct IconSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Icon") {
            AppIconPicker()
                .offset(y: -10)
        }
        .listRowBackground(store.transparentList ? .clear : Color.list)
    }
}

#Preview {
    List {
        IconSettings()
    }
    .environmentObject(ValueStore())
}
