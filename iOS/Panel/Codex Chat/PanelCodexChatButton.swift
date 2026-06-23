import SwiftUI

struct PanelCodexChatButton: View {
    @Binding private var isPresented: Bool
    
    init(_ isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label {
                Text(verbatim: "Codex")
            } icon: {
                Image(systemName: "siri")
                    .foregroundStyle(.orange.gradient)
            }
        }
        .labelStyle(.iconOnly)
        .foregroundStyle(.orange.gradient)
    }
}

private struct PanelCodexChatPresentedKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var panelCodexChatPresented: Binding<Bool> {
        get { self[PanelCodexChatPresentedKey.self] }
        set { self[PanelCodexChatPresentedKey.self] = newValue }
    }
}

struct PanelCodexChatToolbarItems: ToolbarContent {
    @Environment(\.panelCodexChatPresented) private var isPresented
    
    var body: some ToolbarContent {
#if !os(visionOS)
        ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
        
        ToolbarItem(placement: .bottomBar) {
            PanelCodexChatButton(isPresented)
        }
    }
}

extension View {
    func panelCodexChatToolbar() -> some View {
        toolbar {
            PanelCodexChatToolbarItems()
        }
    }
}

#Preview {
    @Previewable @State var isPresented = false
    
    PanelCodexChatButton($isPresented)
        .darkSchemePreferred()
}
