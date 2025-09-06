import SwiftUI
import MapKit

struct Place: Identifiable {
    let id = UUID()
    let name: LocalizedStringResource
    let latitude, longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
    
    init(
        _ name: LocalizedStringResource,
        latitude: Double,
        longitude: Double
    ) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
