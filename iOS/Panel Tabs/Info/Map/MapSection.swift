import SwiftUI
import PteroNet
import MapKit
import SafariCover

struct MapSection: View {
    @Environment(\.displayScale) private var displayScale
    
    private let server: ServerAttributes
    private let node: String
    private let allocations: [AllocationAttributes]
    
    init(_ server: ServerAttributes) {
        self.server = server
        node = server.node
        allocations = server.relationships.allocations.data.map(\.attributes)
    }
    
    @State private var snapshot: UIImage?
    @State private var mapWidth: CGFloat?
    
    @State private var region = MKCoordinateRegion(
        center: .init(latitude: 50.11056, longitude: 8.68017),
        latitudinalMeters: 12000,
        longitudinalMeters: 12000
    )
    
    private let mapHeight: CGFloat = 160
    
    private var isMoscow: Bool {
        allocations.contains {
            $0.ipAlias?.contains("5.231.75") == true
        }
    }
    
    private var mapURL: String {
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
                
                MapSectionPing(allocations)
            }
            .frame(height: 80)
            .padding(.horizontal)
            .offset(y: 5)
            
            mapSnapshotView
        }
        .contentShape(.rect(cornerRadius: 16))
        .contextMenu {
            Button("Open in Apple Maps", image: .maps) {
                openSafari(mapURL)
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
        .task {
            location(node)
        }
    }
    
    private var mapSnapshotView: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            
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
                                
                                Text("Loading map...")
                                    .footnote()
                            }
                            .secondary()
                        }
                }
            }
            .frame(width: width, height: height)
            .onAppear {
                updateSnapshotWidth(width)
            }
            .onChange(of: width) { _, newWidth in
                updateSnapshotWidth(newWidth)
            }
        }
        .frame(maxWidth: .infinity, minHeight: mapHeight, maxHeight: mapHeight)
        .clipShape(.rect(cornerRadius: 12))
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
        makeSnapshot(for: newRegion, mapWidth: mapWidth)
    }
    
    private func makeSnapshot(for region: MKCoordinateRegion, mapWidth: CGFloat?) {
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.scale = displayScale
        options.size = snapshotSize(for: mapWidth)
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
    
    private func snapshotSize(for width: CGFloat?) -> CGSize {
        let baseWidth = width ?? 320
        return CGSize(width: max(baseWidth, 280), height: mapHeight)
    }
    
    private func updateSnapshotWidth(_ width: CGFloat) {
        guard width > 0 else { return }
        
        let adjustedWidth = max(width, 280)
        
        if mapWidth != adjustedWidth {
            mapWidth = adjustedWidth
            makeSnapshot(for: region, mapWidth: adjustedWidth)
        }
    }
}

#Preview {
    MapSection(PreviewProp.serverAttributes)
        .darkSchemePreferred()
}
