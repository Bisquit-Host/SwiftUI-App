import SpriteKit

final class ModelSliderParticleScene: SKScene {
    private let starEmitter = SKEmitterNode()
    private let sparkleEmitter = SKEmitterNode()
    private let initialStarEmitter = SKEmitterNode()
    private let initialSparkleEmitter = SKEmitterNode()
    private var prewarmedSize = CGSize.zero
    private var hasStartedInitialBurst = false

    override init() {
        super.init(size: .init(width: 1, height: 1))

        backgroundColor = .clear
        scaleMode = .resizeFill
        isUserInteractionEnabled = false

        configureStarEmitter(starEmitter)
        configureStarEmitter(initialStarEmitter)
        configureSparkleEmitter(sparkleEmitter)
        configureSparkleEmitter(initialSparkleEmitter)
        initialStarEmitter.numParticlesToEmit = Int(initialStarEmitter.particleBirthRate)
        initialSparkleEmitter.numParticlesToEmit = Int(initialSparkleEmitter.particleBirthRate)
        initialStarEmitter.isPaused = true
        initialSparkleEmitter.isPaused = true
        addChild(starEmitter)
        addChild(sparkleEmitter)
        addChild(initialStarEmitter)
        addChild(initialSparkleEmitter)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)

        update(
            starEmitter,
            verticalOffset: size.height * 0.48,
            minimumSpeed: 52,
            spawnsAcrossWidth: false
        )
        update(
            sparkleEmitter,
            verticalOffset: size.height * 0.52,
            minimumSpeed: 68,
            spawnsAcrossWidth: false
        )
        update(
            initialStarEmitter,
            verticalOffset: size.height * 0.48,
            minimumSpeed: 52,
            spawnsAcrossWidth: true
        )
        update(
            initialSparkleEmitter,
            verticalOffset: size.height * 0.52,
            minimumSpeed: 68,
            spawnsAcrossWidth: true
        )
        prewarmParticlesIfNeeded()
        startInitialBurstIfNeeded()
    }

    private func configureStarEmitter(_ emitter: SKEmitterNode) {
        emitter.particleTexture = SKTexture(imageNamed: "StarParticle")
        emitter.particleBirthRate = 5
        emitter.numParticlesToEmit = 0
        emitter.particleSpeed = 52
        emitter.particleSpeedRange = 14
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = 0.12
        emitter.particleScale = 0.36
        emitter.particleScaleRange = 0.28
        emitter.particleScaleSpeed = -0.035
        emitter.particleAlpha = 0
        emitter.particleAlphaSequence = SKKeyframeSequence(
            keyframeValues: [0, 0.82, 0.7, 0],
            times: [0, 0.12, 0.82, 1]
        )
        emitter.particleColor = .init(red: 1, green: 0.68, blue: 0.06, alpha: 1)
        emitter.particleColorBlendFactor = 0
        emitter.particleRotationRange = .pi * 2
        emitter.particleRotationSpeed = 0.8
        emitter.particleBlendMode = .alpha
    }

    private func configureSparkleEmitter(_ emitter: SKEmitterNode) {
        emitter.particleTexture = SKTexture(imageNamed: "SparkleParticle")
        emitter.particleBirthRate = 3
        emitter.numParticlesToEmit = 0
        emitter.particleSpeed = 68
        emitter.particleSpeedRange = 18
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = 0.16
        emitter.particleScale = 0.42
        emitter.particleScaleRange = 0.32
        emitter.particleScaleSpeed = -0.03
        emitter.particleAlpha = 0
        emitter.particleAlphaSequence = SKKeyframeSequence(
            keyframeValues: [0, 0.9, 0.78, 0],
            times: [0, 0.08, 0.86, 1]
        )
        emitter.particleColor = .init(red: 1, green: 0.88, blue: 0.18, alpha: 1)
        emitter.particleColorBlendFactor = 0
        emitter.particleRotationRange = 0.2
        emitter.particleRotationSpeed = 0.08
        emitter.particleBlendMode = .alpha
    }

    private func update(
        _ emitter: SKEmitterNode,
        verticalOffset: CGFloat,
        minimumSpeed: CGFloat,
        spawnsAcrossWidth: Bool
    ) {
        let flowSpeed = max((size.width + 24) / 3, minimumSpeed)

        emitter.position = .init(x: spawnsAcrossWidth ? size.width / 2 : -12, y: verticalOffset)
        emitter.particlePositionRange = .init(
            dx: spawnsAcrossWidth ? size.width : 8,
            dy: size.height * 0.64
        )
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
        prewarm(starEmitter)
        prewarm(sparkleEmitter)
    }

    private func startInitialBurstIfNeeded() {
        guard !hasStartedInitialBurst, size.width > 1, size.height > 1 else { return }

        hasStartedInitialBurst = true
        initialStarEmitter.isPaused = false
        initialSparkleEmitter.isPaused = false
    }

    private func prewarm(_ emitter: SKEmitterNode) {
        emitter.advanceSimulationTime(
            TimeInterval(emitter.particleLifetime + emitter.particleLifetimeRange)
        )
    }
}
