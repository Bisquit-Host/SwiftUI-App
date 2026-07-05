import SwiftUI

struct CodexChatButton: View {
    @Binding private var isPresented: Bool
    
    init(_ isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }
    
    var body: some View {
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

private struct CodexChatPresentedKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var codexChatPresented: Binding<Bool> {
        get { self[CodexChatPresentedKey.self] }
        set { self[CodexChatPresentedKey.self] = newValue }
    }
}

struct CodexChatToolbarItems: ToolbarContent {
    @Environment(\.codexChatPresented) private var isPresented
    
    var body: some ToolbarContent {
#if !os(visionOS)
        ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
        
        ToolbarItem(placement: .bottomBar) {
            CodexChatButton(isPresented)
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
