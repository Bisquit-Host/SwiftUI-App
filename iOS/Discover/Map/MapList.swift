//import ScrechKit
//import MapKit
//
//struct MapList: View {
//    @Environment(MapModel.self) private var map
//    
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        List {
//            ForEach(map.places, id: \.id) { place in
//#if os(watchOS)
//                ListButton(place.name, actionIcon: "chevron.forward") {
//                    action(place)
//                }
//#else
//                ListButton(
//                    place.name,
//                    icon: "mappin.and.ellipse",
//                    actionIcon: "chevron.forward",
//                    color: .red
//                ) {
//                    action(place)
//                    map.search(.init(latitude: place.latitude, longitude: place.longitude))
//                }
//#endif
//            }
//        }
//        .scrollIndicators(.never)
//        .presentationDetents([.medium])
//        .presentationBackgroundInteraction(.enabled)
//    }
//    
//    private func action(_ place: MapModel.Place) {
//        dismiss()
//        
//        withAnimation {
//            map.region = MKCoordinateRegion(
//                center: CLLocationCoordinate2D(
//                    latitude: place.latitude,
//                    longitude: place.longitude
//                ),
//                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//            )
//        }
//    }
//}

//#Preview {
//    MapList()
//        .darkSchemePreferred()
//        .environment(MapModel())
//}
