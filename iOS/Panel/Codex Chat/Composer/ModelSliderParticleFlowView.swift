import ScrechKit
import SpriteKit

struct ModelSliderParticleFlowView: View {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var scene = ModelSliderParticleScene()

    var body: some View {
        SpriteView(
            scene: scene,
            isPaused: accessibilityReduceMotion || scenePhase != .active,
            preferredFramesPerSecond: 120,
            options: [.allowsTransparency]
        )
        .accessibilityHidden(true)
    }
}

#Preview {
    ModelSliderParticleFlowView()
        .frame(height: 32)
        .background(.white, in: .capsule)
        .padding()
        .background(.black)
}
