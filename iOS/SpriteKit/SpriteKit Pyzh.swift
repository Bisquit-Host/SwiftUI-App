import SpriteKit

final class GameScene: SKScene {
    private let bisquitTexture = SKTexture(imageNamed: "Bisquit")
    private let pyzhTexture = SKTexture(imageNamed: "Пыжмень")
    
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        
        let box = SKSpriteNode(color: .red, size: CGSize(width: 80, height: 80))
        box.position = location
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        
        let randomInt = Int.random(in: 0...10)
        
        switch randomInt {
        case 0:
            box.texture = bisquitTexture
            
        default:
            box.texture = pyzhTexture
        }
        
        addChild(box)
    }
}
