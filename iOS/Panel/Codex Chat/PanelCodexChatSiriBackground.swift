import SwiftUI

struct PanelCodexChatSiriBackground: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    let isVisible: Bool
    
    var body: some View {
        ZStack {
            if isVisible {
                ContentView()
                    .ignoresSafeArea()
                    .transition(transition)
            }
        }
        .animation(animation, value: isVisible)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
    
    private var transition: AnyTransition {
        guard shouldAnimate else { return .identity }
        
        return .opacity
    }
    
    private var animation: Animation? {
        guard shouldAnimate else { return nil }
        
        return .easeInOut(duration: 0.35)
    }
    
    private var shouldAnimate: Bool {
        store.bigAssAnimations && !reduceMotion
    }
}

#Preview {
    PanelCodexChatSiriBackground(isVisible: true)
        .environmentObject(ValueStore())
}
