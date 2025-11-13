import Vortex

extension VortexSystem {
    static let slowSnow = VortexSystem(
        tags: ["circle"],
        position: [0.5, 0],
        shape: .box(width: 1, height: 0),
        birthRate: 5,
        lifespan: 40,
        speed: 0.05,
        speedVariation: 0.1,
        angle: .degrees(180),
        angleRange: .degrees(20),
        size: 0.25,
        sizeVariation: 0.4
    )
}
