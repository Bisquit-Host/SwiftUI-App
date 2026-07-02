import ScrechKit

struct ChatComposerSettingsMenu: View {
    let logout: () -> Void
    
    var body: some View {
        Menu {
            Button("Log out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive, action: logout)
        } label: {
            Label("Settings", systemImage: "slider.horizontal.3")
                .labelStyle(.iconOnly)
                .foregroundStyle(.foreground)
                .frame(35)
                .contentShape(.rect)
        }
    }
}

#Preview {
    ChatComposerSettingsMenu {}
        .darkSchemePreferred()
}
