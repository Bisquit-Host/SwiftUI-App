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
        .onReceive(timer) { _ in
            checkPing()
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
    
    private func checkPing() {
        guard let address else {
            print("Ping error: Invalid Address")
            return
        }
        
        tcpPing(host: address, port: 22) {
            switch $0 {
            case .success(let pingDuration):
                let ping = Int(round(pingDuration * 1000))
                
                Task { @MainActor in
                    pings.append(ping)
                    
                    if pings.count > 1 {
                        self.ping = pings.min()
                        pings = []
                    }
                }
            default:
                break
            }
        }
    }
}

#Preview {
    MapSectionPing([PreviewProp.allocationAttributes])
        .darkSchemePreferred()
}
