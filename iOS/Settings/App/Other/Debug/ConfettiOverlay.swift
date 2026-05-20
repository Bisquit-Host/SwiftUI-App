import SwiftUI
import Vortex

struct ConfettiOverlay: View {
    @Environment(ConfettiVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        if store.bigAssAnimations {
            VortexViewReader { proxy in
                VortexView(vm.makeConfettiSystem()) {
                    Rectangle()
                        .fill(.white)
                        .frame(16)
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
            .hapticOn(vm.confettiTrigger, as: .success, disabled: reduceMotion || System.lowPowerMode)
        }
    }
}

extension View {
    func confettiOverlay() -> some View {
        self.overlay {
            ConfettiOverlay()
        }
    }
}
