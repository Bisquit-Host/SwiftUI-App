import ScrechKit

struct DebugSettingsPushNotifications: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        if let pushToken = store.pushToken {
            Section(String("Push token")) {
                Text(displayedPushToken(pushToken))
                
                Button("Copy") {
                    SystemAlert.copied()
                    Pasteboard.copy(pushToken)
                }
            }
        }
    }
    
    private func displayedPushToken(_ pushToken: String) -> String {
        guard pushToken.count > 8 else { return pushToken }
        return "\(pushToken.prefix(4))...\(pushToken.suffix(4))"
    }
}

#Preview {
    DebugSettingsPushNotifications()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
