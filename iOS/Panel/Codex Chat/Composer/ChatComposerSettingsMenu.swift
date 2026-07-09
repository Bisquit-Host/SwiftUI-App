import ScrechKit

struct ChatComposerSettingsMenu: View {
    @Binding private var webSearchEnabled: Bool
    @Binding private var fullAccess: Bool
    private let preferencesLocked: Bool
    private let preferencesChanged: () -> Void
    private let logout: () -> Void
    
    init(
        webSearchEnabled: Binding<Bool>,
        fullAccess: Binding<Bool>,
        preferencesLocked: Bool,
        preferencesChanged: @escaping () -> Void,
        logout: @escaping () -> Void
    ) {
        _webSearchEnabled = webSearchEnabled
        _fullAccess = fullAccess
        self.preferencesLocked = preferencesLocked
        self.preferencesChanged = preferencesChanged
        self.logout = logout
    }
    
    var body: some View {
        Menu {
            Section {
                Toggle(isOn: $webSearchEnabled) {
                    Label("Web search", systemImage: "globe")
                }
                .disabled(preferencesLocked)
                
                Toggle(isOn: $fullAccess) {
                    Label("Full access", systemImage: "exclamationmark.shield")
                }
                .disabled(preferencesLocked)
            }
            
            Section {
                Button("Log out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive, action: logout)
            }
        } label: {
            Label("Settings", systemImage: "gearshape")
                .labelStyle(.iconOnly)
                .foregroundStyle(.foreground)
                .frame(35)
                .contentShape(.rect)
        }
        .onChange(of: webSearchEnabled) {
            preferencesChanged()
        }
        .onChange(of: fullAccess) {
            preferencesChanged()
        }
    }
}

#Preview {
    ChatComposerSettingsMenu(
        webSearchEnabled: .constant(true),
        fullAccess: .constant(false),
        preferencesLocked: false,
        preferencesChanged: {},
        logout: {}
    )
        .darkSchemePreferred()
}
