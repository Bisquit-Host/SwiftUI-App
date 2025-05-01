import SwiftUI
import MapKit
import SafariCover

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
        ["Fabric", "Forge", "Fusion"]
            .contains(node)
    }
    
    private var mapUrl: String {
        if isMoscow {
            "https://maps.apple.com/place?address=Moscow,%20Russia&auid=12646685065745334150&coordinate=55.758664,37.619292&lsp=6489&name=Moscow&map=explore"
        } else {
            "https://maps.apple.com/place?address=Frankfurt,%20Hesse,%20Germany&auid=7497387549351306333&coordinate=50.110556,8.680173&lsp=7618&name=Frankfurt&map=explore"
        }
    }
    
    var body: some View {
        Menu {
            Button {
                openSafari(mapUrl)
            } label: {
                Label("Open in Apple Maps", systemImage: "map")
            }
        } label: {
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
                .frame(height: 80)
                .padding(.horizontal)
                .offset(y: 5)
                
                Map(position: $cameraPosition, interactionModes: [])
            }
        }
        .foregroundStyle(.foreground)
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
        .onDisappear {
            timer.upstream.connect().cancel()
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
        
        tcpPing(host: address, port: 22) { result in
            switch result {
            case .success(let pingDuration):
                self.ping = Int(round(pingDuration * 1000))
                
            default:
                break
            }
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
