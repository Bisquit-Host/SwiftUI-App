import SwiftUI
import BisquitoNet

struct VDSProtectionAttackRowView: View {
    private let attack: VDSProtectionAttack
    
    init(_ attack: VDSProtectionAttack) {
        self.attack = attack
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(attack.dstAddress ?? String(localized: "Attack"))
                .subheadline(.semibold)
            
            Group {
                if let started = attack.startedAt ?? attack.createdAt {
                    Text("Started \(formatted(started))")
                        .footnote()
                }
                
                if let ended = attack.endedAt {
                    Text("Ended \(formatted(ended))")
                        .footnote()
                } else {
                    Text("Ongoing")
                        .footnote()
                }
                
                if let rate = attack.sampleRate {
                    Text("Sample rate \(rate)")
                        .caption()
                }
            }
            .secondary()
            
            Text(attack.id)
                .caption()
                .secondary()
                .lineLimit(1)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func formatted(_ date: Date) -> String {
        date.formatted(date: .numeric, time: .shortened)
    }
}
