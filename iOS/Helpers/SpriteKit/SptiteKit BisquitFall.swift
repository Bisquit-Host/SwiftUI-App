import ScrechKit
import SpriteKit

final class SceneBisquitFall: SKScene {
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        // Use the screen from context (iOS 26+ guidance), fall back to the view/scene
        let bounds: CGRect = view.window?.windowScene?.screen.bounds ?? view.bounds
        
        guard let particles = SKEmitterNode(fileNamed: "Bisquits") else {
            return
        }
        
        particles.name = "bisquitsEmitter"
        
        let range = max(bounds.width, bounds.height)
        particles.position = CGPoint(x: frame.midX, y: frame.maxY)
        particles.particlePositionRange = CGVector(dx: range, dy: range)
        
        addChild(particles)
    }
}

struct BisquitFall: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.colorScheme) private var appearance
    
    private var scene: SKScene {
        let scene = SceneBisquitFall()
        
        scene.scaleMode = .resizeFill
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)
#if !os(tvOS)
        scene.backgroundColor = .systemBackground
#endif
        return scene
    }
    
    var body: some View {
        if store.enableBisquitFall, !System.lowPowerMode {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .background(appearance == .light ? .white : .black)
        }
    }
}

#Preview {
    BisquitFall()
        .environmentObject(ValueStore())
}
