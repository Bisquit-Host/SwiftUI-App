import SwiftUI
import BisquitoNet

struct VDSProtectionAttackCard: View {
    private let attack: VDSProtectionAttack

    init(_ attack: VDSProtectionAttack) {
        self.attack = attack
    }

    var body: some View {
        VDSProtectionAttackRowView(attack)
            .padding(10)
            .background(.background.opacity(0.4), in: .rect(cornerRadius: 10))
    }
}
