import SwiftUI

struct CodexChatButton: View {
    @Environment(\.panelAIAgentEnabled) private var isEnabled
    
    @Binding private var isPresented: Bool
    
    init(_ isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }
    
    var body: some View {
        if isEnabled {
            Button {
                isPresented = true
            } label: {
                Label {
                    Text("Codex")
                } icon: {
                    Image(systemName: "siri")
                }
            }
            .labelStyle(.iconOnly)
            .tint(Color.orange.gradient)
        }
    }
}

private struct CodexChatPresentedKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

private struct PanelAIAgentEnabledKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var codexChatPresented: Binding<Bool> {
        get { self[CodexChatPresentedKey.self] }
        set { self[CodexChatPresentedKey.self] = newValue }
    }
    
    var panelAIAgentEnabled: Bool {
        get { self[PanelAIAgentEnabledKey.self] }
        set { self[PanelAIAgentEnabledKey.self] = newValue }
    }
}

struct CodexChatToolbarItems: ToolbarContent {
    @Environment(\.codexChatPresented) private var isPresented
    @Environment(\.panelAIAgentEnabled) private var isEnabled
    
    var body: some ToolbarContent {
        if isEnabled {
#if !os(visionOS)
            ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
            PanelToolbarItem(placement: .bottomBar) {
                CodexChatButton(isPresented)
            }
        }
    }
}

extension View {
    func codexChatToolbar() -> some View {
        toolbar {
            CodexChatToolbarItems()
        }
    }
}

#Preview {
    @Previewable @State var isPresented = false
    
    CodexChatButton($isPresented)
        .darkSchemePreferred()
}
