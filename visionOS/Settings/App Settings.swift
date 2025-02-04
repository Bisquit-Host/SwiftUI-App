import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
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
            
            Toggle("Developer mode", isOn: $store.devMode)
        }
        .padding()
    }
}

#Preview {
    AppSettings()
        .environmentObject(ValueStore())
        .padding()
        .glassBackgroundEffect()
}
