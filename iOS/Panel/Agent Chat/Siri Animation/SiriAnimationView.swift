import SwiftUI

struct SiriAnimationView: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    let isGenerating: Bool
    
    // Gradient and masking
    @State private var gradientSpeed: Float = 0.03
    @State private var maskTimer: Float = 0
    
    var body: some View {
        ZStack {
            // Colorful animated gradient
            MeshGradientView(maskTimer: $maskTimer, gradientSpeed: $gradientSpeed)
                .scaleEffect(1.3) // avoid clipping
                .opacity(containerOpacity)
                .mask {
                    ZStack {
                        Rectangle()
                            .fill(.white)

                        ConcentricRectangle()
                            .fill(.black)
                            .padding(8)
                            .scaleEffect(computedScale)
                            .blur(radius: animatedMaskBlur)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
            }

            if isGenerating {
                ConcentricRectangle()
                    .stroke(.white, style: .init(lineWidth: 4))
                    .padding(2)
                    .blur(radius: 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
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
