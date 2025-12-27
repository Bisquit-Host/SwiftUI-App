import SwiftUI
import Vortex

struct ConfettiOverlay: View {
    @Environment(ConfettiVM.self) private var vm
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        VortexViewReader { proxy in
            VortexView(vm.makeConfettiSystem()) {
                Rectangle()
                    .fill(.white)
                    .frame(width: 16, height: 16)
                    .tag("square")
                
                Circle()
                    .fill(.white)
                    .frame(width: 16)
                    .tag("circle")
            }
            .onChange(of: vm.confettiTrigger) {
                if !reduceMotion && !System.lowPowerMode {
                    vm.spawnConfetti(using: proxy)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .sensoryFeedback(.success, trigger: vm.confettiTrigger)
    }
}

extension View {
    func confettiOverlay() -> some View {
        self.overlay {
            ConfettiOverlay()
        }
    }
}
