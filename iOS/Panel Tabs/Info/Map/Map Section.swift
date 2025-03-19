import SwiftUI
import MapKit

struct MapSection: View {
    private let address: String?
    private let node: String
    
    init(_ address: String?, node: String) {
        self.address = address
        self.node = node
    }
    
    private let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    @State private var ping: Int?
    @State private var cameraPosition: MapCameraPosition = .region(
        .init(
            center: .init(
                latitude: 50.11056,
                longitude: 8.68017
            ),
            latitudinalMeters: 12000,
            longitudinalMeters: 12000
        )
    )
    
    private var isMoscow: Bool {
        ["Fabric", "Forge", "Fusion"].contains(node)
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Location")
                        .footnote()
                        .secondary()
                    
                    Text(node)
                        .title3(.bold, design: .rounded)
                    
                    if isMoscow {
                        Text("Moscow, Russia")
                            .semibold()
                            .rounded()
                    } else {
                        Text("Frankfurt, Germany")
                            .semibold()
                            .rounded()
                    }
                }
                
                Spacer()
                
                if let ping {
                    Text("\(ping) ms")
                        .monospacedDigit()
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
                }
            }
            .frame(height: 80)
            .padding(.horizontal)
            .offset(y: 5)
            
            Map(position: $cameraPosition, interactionModes: [])
        }
        .clipShape(.rect(cornerRadius: 16))
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .frame(height: 250)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
        .onReceive(timer) { _ in
            checkPing()
        }
        .task {
            location(node)
        }
    }
    
    private func checkPing() {
        guard let address else {
            print("Ping error: Invalid Address")
            return
        }
        
        Task {
            let pingResult = await SwiftyPing.pingServer(address)
            
            guard pingResult.error == nil else {
                print("Ping error:", pingResult.error ?? "Unknown")
                return
            }
            
            let pingDuration = Int(round(pingResult.duration * 1000))
            self.ping = pingDuration
        }
    }
    
    private func location(_ node: String) {
        let scaleMeters = isMoscow ? 25000.0 : 12000.0
        let center: CLLocationCoordinate2D
        
        if isMoscow {
            center = .init( // Moscow
                latitude: 55.75866,
                longitude: 37.61929
            )
        } else {
            center = .init( // Frankfurt
                latitude: 50.11056,
                longitude: 8.68017
            )
        }
        
        cameraPosition = .region(
            .init(
                center: center,
                latitudinalMeters: scaleMeters,
                longitudinalMeters: scaleMeters
            )
        )
    }
}

//#Preview {
//    MapSection()
//}
