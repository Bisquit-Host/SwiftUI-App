import SwiftUI

struct CodexChatSiriBackground: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    let isGenerating: Bool
    
    var body: some View {
        ContentView(isGenerating: isGenerating)
            .ignoresSafeArea()
            .animation(animation, value: isGenerating)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
    
    private var animation: Animation? {
        guard shouldAnimate else { return nil }
        return .easeInOut(duration: 0.5)
    }
    
    private var shouldAnimate: Bool {
        store.bigAssAnimations && !reduceMotion
    }
}

#Preview {
    CodexChatSiriBackground(isGenerating: true)
        .environmentObject(ValueStore())
}
