import ScrechKit

struct TwoFAActionTile: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let icon: String
    var action: () -> Void
    
    init(_ title: LocalizedStringKey, subtitle: LocalizedStringKey, icon: String, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            TwoFAActionTileContent(title, subtitle: subtitle, icon: icon)
        }
        .buttonStyle(.plain)
    }
}
