import SwiftUI
import MapKit
import Kingfisher
import Observation

@Observable
final class MapViewVM {
    var snapshot: UIImage?
    var mapWidth: CGFloat?
    
    var region = MKCoordinateRegion(
        center: .init(latitude: 50.11056, longitude: 8.68017),
        latitudinalMeters: 12000,
        longitudinalMeters: 12000
    )
    
    let mapHeight: CGFloat = 160
    
    func updateRegion(isMoscow: Bool, displayScale: CGFloat) {
        let center: CLLocationCoordinate2D
        
        if isMoscow {
            center = .init(latitude: 55.75866, longitude: 37.61929)
        } else {
            center = .init(latitude: 50.11056, longitude: 8.68017)
        }
        
        let scaleMeters = isMoscow ? 25000.0 : 12000
        let newRegion = MKCoordinateRegion(center: center, latitudinalMeters: scaleMeters, longitudinalMeters: scaleMeters)
        
        region = newRegion
        makeSnapshot(for: newRegion, mapWidth: mapWidth, displayScale: displayScale)
    }
    
    func updateSnapshotWidth(_ width: CGFloat, displayScale: CGFloat) {
        guard width > 0 else { return }
        
        let adjustedWidth = max(width, 280)
        
        if mapWidth != adjustedWidth {
            mapWidth = adjustedWidth
            makeSnapshot(for: region, mapWidth: adjustedWidth, displayScale: displayScale)
        }
    }
    
    func makeSnapshot(for region: MKCoordinateRegion, mapWidth: CGFloat?, displayScale: CGFloat) {
        let cacheKey = snapshotCacheKey(for: region, mapWidth: mapWidth, displayScale: displayScale)
        
        KingfisherManager.shared.cache.retrieveImage(forKey: cacheKey) { result in
            Task { @MainActor in
                if case let .success(value) = result, let image = value.image {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.snapshot = image
                    }
                    
                    return
                }
                
                self.createSnapshot(for: region, mapWidth: mapWidth, cacheKey: cacheKey, displayScale: displayScale)
            }
        }
    }
    
    private func createSnapshot(for region: MKCoordinateRegion, mapWidth: CGFloat?, cacheKey: String, displayScale: CGFloat) {
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.scale = displayScale
        options.size = snapshotSize(for: mapWidth)
        options.showsBuildings = true
        options.pointOfInterestFilter = .excludingAll
        
        let snapshotter = MKMapSnapshotter(options: options)
        
        snapshotter.start { snapshot, error in
            Task { @MainActor in
                guard let snapshot else {
                    if let error {
                        print("Map snapshot error:", error.localizedDescription)
                    }
                    
                    return
                }
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.snapshot = snapshot.image
                }
                
                let kfOptions: KingfisherParsedOptionsInfo = .init([
                    .cacheSerializer(FormatIndicatedCacheSerializer.png)
                ])
                
                KingfisherManager.shared.cache.store(snapshot.image, forKey: cacheKey, options: kfOptions)
            }
        }
    }
    
    private func snapshotCacheKey(for region: MKCoordinateRegion, mapWidth: CGFloat?, displayScale: CGFloat) -> String {
        let center = region.center
        let span = region.span
        let width = snapshotSize(for: mapWidth).width
        
        return "map:\(center.latitude):\(center.longitude):\(span.latitudeDelta):\(span.longitudeDelta):w=\(Int(width)):scale=\(displayScale)"
    }
    
    private func snapshotSize(for width: CGFloat?) -> CGSize {
        let baseWidth = width ?? 320
        return CGSize(width: max(baseWidth, 280), height: mapHeight)
    }
}
