import SwiftUI
import MapKit

@Observable
final class MapVM: NSObject, CLLocationManagerDelegate {
    var position: MapCameraPosition = .automatic
    var searchResults: [MKMapItem] = []
    
    private var locationManager: CLLocationManager?
    
    let places = [
        Place("Biscuits N' porn",
              latitude: 35.99207,
              longitude: -75.648501),
        
        Place("Храм святителя Николая\nМирликийского в Пыжах",
              latitude: 55.810162,
              longitude: 37.463209),
        
        Place("Деревня Пыжи\n(Кировская обл.)",
              latitude: 58.166037,
              longitude: 47.165959)
    ]
    
    var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 35.99207,
            longitude: -75.648501
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.05,
            longitudeDelta: 0.05
        )
    )
    
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
        
        init(_ name: LocalizedStringResource,
             latitude: Double,
             longitude: Double
        ) {
            self.name = name
            self.latitude = latitude
            self.longitude = longitude
        }
    }
    
    //#if !os(watchOS)
    //    func search(_ coordinate: CLLocationCoordinate2D) {
    //        let request = MKLocalSearch.Request()
    //
    //        request.resultTypes = .pointOfInterest
    //        request.region = MKCoordinateRegion(
    //            center: coordinate, span: MKCoordinateSpan(
    //                latitudeDelta: 0.05,
    //                longitudeDelta: 0.05
    //            )
    //        )
    //
    //        Task {
    //            let search = MKLocalSearch(request: request)
    //            let response = try? await search.start()
    //
    //            withAnimation {
    //                searchResults = response?.mapItems ?? []
    //            }
    //        }
    //    }
    //    func search(for query: String) {
    //        let request = MKLocalSearch.Request()
    //
    //        request.naturalLanguageQuery = query
    //        request.resultTypes = .pointOfInterest
    //        request.region = MKCoordinateRegion(
    //            center: .cafe, span: .init(latitudeDelta: 35.99207, longitudeDelta: -75.648501)
    //        )
    //
    //        Task {
    //            let search = MKLocalSearch(request: request)
    //            let response = try? await search.start()
    //
    //            withAnimation {
    //                searchResults = response?.mapItems ?? []
    //            }
    //        }
    //    }
    //#endif
    
    func check() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            print("Location services unavailible")
        }
    }
    
    private func checkAuth() {
        guard let locationManager else {
            return
        }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            print("Access restricted")
            
        case .denied:
            print("Access denied")
            
        case .authorizedAlways, .authorizedWhenInUse:
            let span = MKCoordinateSpan(
                latitudeDelta: 0.05,
                longitudeDelta: 0.05
            )
            
            region = MKCoordinateRegion(
                center: locationManager.location!.coordinate,
                span: span
            )
            
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuth()
    }
}
