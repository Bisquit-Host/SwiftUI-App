import SwiftUI
import Calagopus

struct MapSectionPing: View {
    private let allocations: [CalagopusServerAllocation]
    
    init(_ allocations: [CalagopusServerAllocation]) {
        self.allocations = allocations
    }
    
    @State private var ping: Int?
    @State private var pings: [Int] = []
    
    private var address: String? {
        let allocation = allocations.first {
            $0.isPrimary
        }
        
        guard let allocation else { return nil }
        
        if let ipAlias = allocation.ipAlias {
            return ipAlias
        } else {
            return allocation.ip
        }
    }
    
    var body: some View {
        VStack {
            if let ping {
                Text("\(ping) ms")
                    .animation(.default, value: ping)
                    .numericTransition()
                    .monospacedDigit()
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray.opacity(0.25), lineWidth: 1)
                    }
            }
        }
        .animation(.default, value: ping)
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await checkPing()
            }
        }
    }
    
    private func checkPing() async {
        guard let address else {
            Logger().error("Ping error: Invalid Address")
            return
        }
        
        guard let measuredPing = try? await tcpPing(host: address, port: 22) else {
            return
        }
        
        let ping = Int(round(measuredPing * 1000))
        pings.append(ping)
        
        if pings.count > 2 {
            self.ping = pings.min()
            pings = []
        }
    }
}

#Preview {
    MapSectionPing([PreviewProp.serverAllocation])
        .darkSchemePreferred()
}
