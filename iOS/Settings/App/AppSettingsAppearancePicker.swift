import SwiftUI
import Appearance

struct AppSettingsAppearancePicker: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        HStack(spacing: 12) {
            GlassyIcon("paintbrush", tint: .blue)
            
            Text("Appearance")
            
            Spacer()
            
            AppearancePicker($store.appearance)
                .tint(.primary)
        }
    }
}

#Preview {
    AppSettingsAppearancePicker()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
