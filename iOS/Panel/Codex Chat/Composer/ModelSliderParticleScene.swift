import SpriteKit

final class ModelSliderParticleScene: SKScene {
    private let starEmitter = SKEmitterNode()
    private let sparkleEmitter = SKEmitterNode()
    private var prewarmedSize = CGSize.zero

    override init() {
        super.init(size: .init(width: 1, height: 1))

        backgroundColor = .clear
        scaleMode = .resizeFill
        isUserInteractionEnabled = false

        configureStarEmitter()
        configureSparkleEmitter()
        addChild(starEmitter)
        addChild(sparkleEmitter)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)

        update(starEmitter, verticalOffset: size.height * 0.48, minimumSpeed: 52)
        update(sparkleEmitter, verticalOffset: size.height * 0.52, minimumSpeed: 68)
        prewarmParticlesIfNeeded()
    }

    private func configureStarEmitter() {
        starEmitter.particleTexture = SKTexture(imageNamed: "StarParticle")
        starEmitter.particleBirthRate = 5
        starEmitter.numParticlesToEmit = 0
        starEmitter.particleSpeed = 52
        starEmitter.particleSpeedRange = 14
        starEmitter.emissionAngle = 0
        starEmitter.emissionAngleRange = 0.12
        starEmitter.particleScale = 0.36
        starEmitter.particleScaleRange = 0.28
        starEmitter.particleScaleSpeed = -0.035
        starEmitter.particleAlpha = 0
        starEmitter.particleAlphaSequence = SKKeyframeSequence(
            keyframeValues: [0, 0.82, 0.7, 0],
            times: [0, 0.12, 0.82, 1]
        )
        starEmitter.particleColor = .init(red: 1, green: 0.68, blue: 0.06, alpha: 1)
        starEmitter.particleColorBlendFactor = 0
        starEmitter.particleRotationRange = .pi * 2
        starEmitter.particleRotationSpeed = 0.8
        starEmitter.particleBlendMode = .alpha
    }

    private func configureSparkleEmitter() {
        sparkleEmitter.particleTexture = SKTexture(imageNamed: "SparkleParticle")
        sparkleEmitter.particleBirthRate = 3
        sparkleEmitter.numParticlesToEmit = 0
        sparkleEmitter.particleSpeed = 68
        sparkleEmitter.particleSpeedRange = 18
        sparkleEmitter.emissionAngle = 0
        sparkleEmitter.emissionAngleRange = 0.16
        sparkleEmitter.particleScale = 0.42
        sparkleEmitter.particleScaleRange = 0.32
        sparkleEmitter.particleScaleSpeed = -0.03
        sparkleEmitter.particleAlpha = 0
        sparkleEmitter.particleAlphaSequence = SKKeyframeSequence(
            keyframeValues: [0, 0.9, 0.78, 0],
            times: [0, 0.08, 0.86, 1]
        )
        sparkleEmitter.particleColor = .init(red: 1, green: 0.88, blue: 0.18, alpha: 1)
        sparkleEmitter.particleColorBlendFactor = 0
        sparkleEmitter.particleRotationRange = 0.2
        sparkleEmitter.particleRotationSpeed = 0.08
        sparkleEmitter.particleBlendMode = .alpha
    }

    private func update(
        _ emitter: SKEmitterNode,
        verticalOffset: CGFloat,
        minimumSpeed: CGFloat
    ) {
        let flowSpeed = max((size.width + 24) / 5, minimumSpeed)

        emitter.position = .init(x: -12, y: verticalOffset)
        emitter.particlePositionRange = .init(dx: 8, dy: size.height * 0.64)
        emitter.particleSpeed = flowSpeed
        emitter.particleSpeedRange = flowSpeed * 0.2
        emitter.particleLifetime = max((size.width + 24) / flowSpeed, 1)
        emitter.particleLifetimeRange = 0.35
    }

    private func prewarmParticlesIfNeeded() {
        guard size.width > 1,
              size.height > 1,
              abs(size.width - prewarmedSize.width) > 1
              || abs(size.height - prewarmedSize.height) > 1 else { return }

        prewarmedSize = size
        starEmitter.advanceSimulationTime(
            TimeInterval(starEmitter.particleLifetime + starEmitter.particleLifetimeRange)
        )
        sparkleEmitter.advanceSimulationTime(
            TimeInterval(sparkleEmitter.particleLifetime + sparkleEmitter.particleLifetimeRange)
        )
    }
}
