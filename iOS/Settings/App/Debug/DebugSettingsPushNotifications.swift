import ScrechKit

struct DebugSettingsPushNotifications: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        if let pushToken = store.pushToken {
            Section("Push token") {
                Text(pushToken)
                
                Button("Copy") {
                    Pasteboard.copy(pushToken)
                }
            }
        }
    }
}

#Preview {
    DebugSettingsPushNotifications()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
