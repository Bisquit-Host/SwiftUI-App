import SwiftUI
import PteroNet
import MapKit
import SafariCover

struct MapSection: View {
    private let server: ServerAttributes
    private let node: String
    private let allocations: [AllocationAttributes]
    
    init(_ server: ServerAttributes) {
        self.server = server
        node = server.node
        allocations = server.relationships.allocations.data.map(\.attributes)
    }
    
    private let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    @State private var ping: Int?
    @State private var pings: [Int] = []
    
    @State private var region = MKCoordinateRegion(
        center: .init(latitude: 50.11056, longitude: 8.68017),
        latitudinalMeters: 12000,
        longitudinalMeters: 12000
    )
    
    @State private var snapshot: UIImage?
    
    private let mapHeight = 160.0
    
    private var address: String? {
        let allocation = server.relationships.allocations.data.map(\.attributes).first {
            $0.isDefault
        }
        
        guard let allocation else { return nil }
        
        if let ipAlias = allocation.ipAlias {
            return ipAlias
        } else {
            return allocation.ip
        }
    }
    
    private var isMoscow: Bool {
        allocations.contains {
            $0.ipAlias?.contains("5.231.75") == true
        }
    }
    
    private var mapUrl: String {
        if isMoscow {
            "https://maps.apple.com/place?address=Moscow,%20Russia&auid=12646685065745334150&coordinate=55.758664,37.619292&lsp=6489&name=Moscow&map=explore"
        } else {
            "https://maps.apple.com/place?address=Frankfurt,%20Hesse,%20Germany&auid=7497387549351306333&coordinate=50.110556,8.680173&lsp=7618&name=Frankfurt&map=explore"
        }
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
                    
                    Text(isMoscow ? "Moscow, Russia" : "Frankfurt, Germany")
                        .semibold()
                        .rounded()
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
            
            mapSnapshotView
        }
        .contentShape(.rect(cornerRadius: 16))
        .contextMenu {
            Button("Open in Apple Maps", image: .maps) {
                openSafari(mapUrl)
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
    
    private var mapSnapshotView: some View {
        ZStack {
            if let snapshot {
                Image(uiImage: snapshot)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        VStack(spacing: 6) {
                            ProgressView()
                                .secondary()
                            
                            Text("Loading map...")
                                .footnote()
                                .secondary()
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, minHeight: mapHeight, maxHeight: mapHeight)
        .clipShape(.rect(cornerRadius: 12))
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
    
    private func location(_ node: String) {
        let center: CLLocationCoordinate2D
        
        if isMoscow {
            // Moscow
            center = .init(latitude: 55.75866, longitude: 37.61929)
        } else {
            // Frankfurt
            center = .init(latitude: 50.11056, longitude: 8.68017)
        }
        
        let scaleMeters = isMoscow ? 25000.0 : 12000
        let newRegion = MKCoordinateRegion(center: center, latitudinalMeters: scaleMeters, longitudinalMeters: scaleMeters)
        
        region = newRegion
        makeSnapshot(for: newRegion)
    }
    
    private func makeSnapshot(for region: MKCoordinateRegion) {
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.scale = UIScreen.main.scale
        options.size = snapshotSize()
        options.showsBuildings = true
        options.pointOfInterestFilter = .excludingAll
        
        let snapshotter = MKMapSnapshotter(options: options)
        
        snapshotter.start { snapshot, error in
            guard let snapshot else {
                if let error {
                    print("Map snapshot error:", error.localizedDescription)
                }
                
                return
            }
            
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.snapshot = snapshot.image
                }
            }
        }
    }
    
    private func snapshotSize() -> CGSize {
        let width = UIScreen.main.bounds.width - 32
        return CGSize(width: max(width, 280), height: mapHeight)
    }
}

#Preview {
    MapSection(PreviewProp.serverAttributes)
        .darkSchemePreferred()
}
