import SwiftUI

struct AgentChatSiriBackground: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var origin = CGPoint(x: 0.5, y: 0.5)
    @State private var counter = 0

    let isGenerating: Bool
    
    var body: some View {
        PhoneBackground(state: state, origin: $origin, counter: $counter)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    private var state: SiriState {
        isGenerating ? .thinking : .none
    }
}

#Preview {
    AgentChatSiriBackground(isGenerating: true)
        .environmentObject(ValueStore())
}
