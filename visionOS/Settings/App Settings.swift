import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Toggle("Developer mode", isOn: $store.devMode)
        }
        .padding()
        .navigationTitle("Settings")
#if os(visionOS)
        .ornament(attachmentAnchor: .scene(.bottom)) {
#warning("search by ornament and replace everywhere with a modifier")
            Button("Dismiss") {
                dismiss()
            }
        }
#endif
    }
}

#Preview {
    AppSettings()
        .environmentObject(ValueStore())
        .padding()
        .glassBackgroundEffect()
}
