import SwiftUI
import PteroNet

struct MapSectionPing: View {
    private let allocations: [AllocationAttributes]
    
    init(_ allocations: [AllocationAttributes]) {
        self.allocations = allocations
    }
    
    @State private var ping: Int?
    @State private var pings: [Int] = []
    
    private let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    private var address: String? {
        let allocation = allocations.first {
            $0.isDefault
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
        .onReceive(timer) { _ in
            Task {
                await checkPing()
            }
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
    
    private func checkPing() async {
        guard let address else {
            print("Ping error: Invalid Address")
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
    MapSectionPing([PreviewProp.allocationAttributes])
        .darkSchemePreferred()
}
