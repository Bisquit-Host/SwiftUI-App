import SwiftUI
import Vortex

struct ConfettiOverlay: View {
    @Environment(ConfettiVM.self) private var vm
    
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
                vm.spawnConfetti(using: proxy)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

extension View {
    func confettiOverlay() -> some View {
        self.overlay {
            ConfettiOverlay()
        }
    }
}
