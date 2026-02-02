import SwiftUI

struct GlassyActionCard: View {
    private let title: LocalizedStringKey
    private let icon: String
    private let actionIcon: String
    private let tint: Color
    private let role: ButtonRole?
    private let action: () -> Void
    
    init(_ title: LocalizedStringKey, icon: String, actionIcon: String = "chevron.right", tint: Color, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.actionIcon = actionIcon
        self.tint = tint
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Button(role: role, action: action) {
            HStack(spacing: 12) {
                GlassyIcon(icon, tint: tint)
                
                Text(title)
                    .subheadline(.semibold)
                
                Spacer()
                
                Image(systemName: actionIcon)
                    .footnote()
                    .secondary()
            }
        }
        .buttonStyle(.plain)
    }
}
