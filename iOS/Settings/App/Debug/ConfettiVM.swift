import SwiftUI
import Vortex

@Observable
final class ConfettiVM {
    var confettiTrigger = true
    private var isConfettiVisible = false
    private var confettiTask: Task<Void, Never>?
    
    func launchConfetti() {
        confettiTask?.cancel()
        
        if !isConfettiVisible {
            isConfettiVisible = true
            confettiTrigger.toggle()
        } else {
            confettiTrigger.toggle()
        }
        
        confettiTask = Task {
            try? await Task.sleep(for: .seconds(4.5))
            
            await MainActor.run {
                isConfettiVisible = false
            }
        }
    }
    
    func spawnConfetti(using proxy: VortexProxy) {
        for _ in 0..<5 {
            let x = Double.random(in: 0.2...0.8)
            let y = Double.random(in: 0.2...0.8)
            proxy.particleSystem?.position = [x, y]
            proxy.burst()
        }
    }
    
    func makeConfettiSystem() -> VortexSystem {
        let system = VortexSystem.confetti.makeUniqueCopy()
        system.burstCount = 50
        
        return system
    }
}
