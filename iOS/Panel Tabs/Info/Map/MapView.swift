import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.displayScale) private var displayScale
    
    private let isMoscow: Bool
    
    init(_ isMoscow: Bool) {
        self.isMoscow = isMoscow
    }
    
    @State private var snapshot: UIImage?
    @State private var mapWidth: CGFloat?
    
    @State private var region = MKCoordinateRegion(
        center: .init(latitude: 50.11056, longitude: 8.68017),
        latitudinalMeters: 12000,
        longitudinalMeters: 12000
    )
    
    private let mapHeight: CGFloat = 160
    
    var body: some View {
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
        .task {
            updateRegion()
        }
        .onChange(of: isMoscow) { _, _ in
            updateRegion()
        }
    }
    
    private func updateRegion() {
        let center: CLLocationCoordinate2D
        
        if isMoscow {
            center = .init(latitude: 55.75866, longitude: 37.61929)
        } else {
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
            
            withAnimation(.easeInOut(duration: 0.2)) {
                self.snapshot = snapshot.image
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
