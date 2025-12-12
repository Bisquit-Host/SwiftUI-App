import SwiftUI

struct CloudProtectionAttackRow: View {
    let attack: CloudProtectionAttack
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(attack.dstAddress ?? "Attack")
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
        .padding(10)
        .background(.background.opacity(0.4), in: .rect(cornerRadius: 10))
    }
    
    private func formatted(_ date: Date) -> String {
        date.formatted(date: .numeric, time: .shortened)
    }
}

#Preview {
    CloudProtectionAttackRow(
        attack: .init(
            id: "abc-123-def",
            createdAt: .now,
            startedAt: .now,
            endedAt: nil,
            dstAddress: "203.0.113.10",
            sampleRate: 1000
        )
    )
    .padding()
    .darkSchemePreferred()
}

