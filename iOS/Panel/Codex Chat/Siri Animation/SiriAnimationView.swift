import SwiftUI

struct SiriAnimationView: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    let isGenerating: Bool
    
    // Ripple animation
    @State private var counter = 0
    @State private var origin = CGPoint(x: 0.5, y: 0.5)
    
    // Gradient and masking
    @State private var gradientSpeed: Float = 0.03
    @State private var maskTimer: Float = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Colorful animated gradient
                MeshGradientView(maskTimer: $maskTimer, gradientSpeed: $gradientSpeed)
                    .scaleEffect(1.3) // avoid clipping
                    .opacity(containerOpacity)
                
                if isGenerating {
                    RoundedRectangle(cornerRadius: 52, style: .continuous)
                        .stroke(.white, style: .init(lineWidth: 4))
                        .blur(radius: 4)
                }
                
                PhoneBackground(state: state, origin: $origin, counter: $counter)
                    .mask {
                        AnimatedRectangle(size: geo.size, cornerRadius: 48, t: CGFloat(maskTimer))
                            .scaleEffect(computedScale)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .blur(radius: animatedMaskBlur)
                    }
            }
        }
        .ignoresSafeArea()
        .modifier(RippleEffect(at: origin, trigger: counter))
        .task(id: shouldAnimate) {
            guard shouldAnimate else { return }
            
            while !Task.isCancelled {
                maskTimer += rectangleSpeed + gradientSpeed
                try? await Task.sleep(for: .seconds(0.01))
            }
        }
    }
    
    private var computedScale: CGFloat {
        switch state {
        case .none: 1.2
        case .thinking: 1
        }
    }
    
    private var rectangleSpeed: Float {
        switch state {
        case .none: 0
        case .thinking: 0.03
        }
    }
    
    private var shouldAnimate: Bool {
        store.bigAssAnimations && !reduceMotion && isGenerating
    }
    
    private var animatedMaskBlur: CGFloat {
        switch state {
        case .none: 8
        case .thinking: 28
        }
    }
    
    private var containerOpacity: CGFloat {
        switch state {
        case .none: 0
        case .thinking: 1
        }
    }

    private var state: SiriState {
        isGenerating ? .thinking : .none
    }
}

#Preview("Idle") {
    SiriAnimationView(isGenerating: false)
        .environmentObject(ValueStore())
}

#Preview("Generating") {
    SiriAnimationView(isGenerating: true)
        .environmentObject(ValueStore())
}
