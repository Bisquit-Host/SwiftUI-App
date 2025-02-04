import SwiftUI

struct IconSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("ICON") {
            AppIconPicker()
                .padding(.horizontal, -20)
        }
        .listRowBackground(store.transparentList ? .clear : Color.list)
    }
}

#Preview {
    List {
        IconSettings()
            .environmentObject(ValueStore())
    }
}
