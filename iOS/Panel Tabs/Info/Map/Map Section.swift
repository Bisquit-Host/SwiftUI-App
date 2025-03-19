import SwiftUI
import MapKit

struct MapSection: View {
    private let address: String?
    
    init(_ address: String?) {
        self.address = address
        
        let scaleMeters: CLLocationDistance = 20000
        
        _cameraPosition = State(initialValue: .region(
            .init(
                center: .init(
                    latitude: 50.11056,
                    longitude: 8.68017
                ),
                latitudinalMeters: scaleMeters,
                longitudinalMeters: scaleMeters
            )
        ))
    }
    
    private let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    @State private var cameraPosition: MapCameraPosition
    @State private var ping: Int?
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Location")
                        .footnote()
                        .secondary()
                    
                    Text("Frankfurt, Germany")
                        .semibold()
                        .rounded()
                }
                
                Spacer()
                
                if let ping {
                    Text("\(ping) ms")
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
                }
            }
            .frame(height: 80)
            .padding(.horizontal)
            .offset(y: 5)
            
            ZStack {
                Map(position: $cameraPosition, interactionModes: [])
            }
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
}

//#Preview {
//    MapSection()
//}
