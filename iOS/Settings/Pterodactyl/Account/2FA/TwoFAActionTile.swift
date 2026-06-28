import ScrechKit

struct TwoFAActionTile: View {
    private let title: LocalizedStringKey
    private let icon: String
    private let action: () -> Void
    
    init(_ title: LocalizedStringKey, icon: String, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            TwoFAActionTileContent(title, icon: icon)
        }
        .buttonStyle(.plain)
    }
}
