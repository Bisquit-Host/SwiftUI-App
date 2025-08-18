import ScrechKit
import SpriteKit

final class SceneBisquitFall: SKScene {
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        if let particles = SKEmitterNode(fileNamed: "Bisquits") {
            particles.position = CGPoint(x: frame.midX, y: frame.maxY)
            
            let range = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            particles.particlePositionRange = CGVector(dx: range, dy: range)
            
            addChild(particles)
        }
    }
}

struct BisquitFall: View {
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.colorScheme) private var appearance
    
    private var scene: SKScene {
        let scene = SceneBisquitFall()
        
        scene.scaleMode = .resizeFill
#if !os(tvOS)
        scene.backgroundColor = .systemBackground
#endif
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)
        
        return scene
    }
    
    private let bounds = UIScreen.main.bounds
    
    var body: some View {
        if store.enableBisquitFall, !System.lowPowerMode {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .background(appearance == .light ? .white : .black)
                .frame(width: bounds.width, height: bounds.height)
        }
    }
}

#Preview {
    BisquitFall()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
