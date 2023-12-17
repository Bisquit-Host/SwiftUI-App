import SwiftUI

struct IconSettings: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        Section("ICON") {
            AppIconPicker()
                .padding(.horizontal, -20)
        }
        .listRowBackground(settings.transparentList ? .clear : Color.list)
    }
}
