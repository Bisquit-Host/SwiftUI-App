import SwiftUI

struct IconSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Icon") {
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
