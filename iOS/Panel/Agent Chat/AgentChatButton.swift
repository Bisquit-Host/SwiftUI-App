import SwiftUI

struct AgentChatButton: View {
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
                    Text("Agent")
                } icon: {
                    Image(systemName: "siri")
                }
            }
            .labelStyle(.iconOnly)
            .tint(Color.orange.gradient)
        }
    }
}

private struct AgentChatPresentedKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

private struct PanelAIAgentEnabledKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var agentChatPresented: Binding<Bool> {
        get { self[AgentChatPresentedKey.self] }
        set { self[AgentChatPresentedKey.self] = newValue }
    }
    
    var panelAIAgentEnabled: Bool {
        get { self[PanelAIAgentEnabledKey.self] }
        set { self[PanelAIAgentEnabledKey.self] = newValue }
    }
}

struct AgentChatToolbarItems: ToolbarContent {
    @Environment(\.agentChatPresented) private var isPresented
    @Environment(\.panelAIAgentEnabled) private var isEnabled
    
    var body: some ToolbarContent {
        if isEnabled {
#if !os(visionOS)
            ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
            PanelToolbarItem(placement: .bottomBar) {
                AgentChatButton(isPresented)
            }
        }
    }
}

extension View {
    func agentChatToolbar() -> some View {
        toolbar {
            AgentChatToolbarItems()
        }
    }
}

#Preview {
    @Previewable @State var isPresented = false
    
    AgentChatButton($isPresented)
        .darkSchemePreferred()
}
