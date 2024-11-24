import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var settings: ValueStorage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            HStack {
                Text("Settings")
                    .title()
                
                Spacer()
                
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            
            Divider()
                .padding(.bottom)
            
            Toggle("Admin mode", isOn: $settings.adminMode)
        }
        .padding()
    }
}

#Preview {
    AppSettings()
        .environmentObject(ValueStorage())
        .padding()
        .glassBackgroundEffect()
}
