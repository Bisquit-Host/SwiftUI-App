import SpriteKit

final class GameScene: SKScene {
    private let bisquitTexture = SKTexture(image: .bisquit)
    
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        let box = SKSpriteNode(
            color: .red,
            size: CGSize(width: 80, height: 80)
        )
        
        box.position = location
        box.physicsBody = .init(rectangleOf: box.size)
        box.texture = bisquitTexture
        
        addChild(box)
    }
}
