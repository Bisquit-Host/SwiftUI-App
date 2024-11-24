import SwiftUI

struct IconSettings: View {
    @EnvironmentObject private var settings: ValueStorage
    
    var body: some View {
        Section("ICON") {
            AppIconPicker()
                .padding(.horizontal, -20)
        }
        .listRowBackground(settings.transparentList ? .clear : Color.list)
    }
}

#Preview {
    List {
        IconSettings()
            .environmentObject(ValueStorage())
    }
}
