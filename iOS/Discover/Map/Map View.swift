import ScrechKit
import MapKit

extension CLLocationCoordinate2D {
    static let cafe = CLLocationCoordinate2DMake(35.99207, -75.648501)
    static let church = CLLocationCoordinate2DMake(55.810162, 37.463209)
    static let village = CLLocationCoordinate2DMake(58.166037, 47.165959)
}

struct MapView: View {
    @Bindable private var map = MapVM()
    
    @State private var showName = false
    //    @State private var sheetList = false
    
    private let places: [MKMapItem] = [
        MKMapItem(placemark: .init(coordinate: .cafe)),
        MKMapItem(placemark: .init(coordinate: .church)),
        MKMapItem(placemark: .init(coordinate: .village))
    ]
    
    var body: some View {
        VStack {
            Map(position: $map.position) {
                //                ForEach(map.searchResults, id: \.self) { place in
                //                    Marker(item: place)
                //                }
                ForEach(map.places, id: \.id) { place in
                    Marker(place.name.key, coordinate: CLLocationCoordinate2D(
                        latitude: place.latitude,
                        longitude: place.longitude
                    ))
                }
                
                //                Marker("Biscuits N' porn", systemImage: "cup.and.saucer", coordinate: .cafe)
                //                    .tint(.orange)
                //
                //                Marker("Храм святителя Николая\nМирликийского в Пыжах", systemImage: "figure.mind.and.body", coordinate: .church)
                //                    .tint(.yellow)
                //
                //                Marker("Деревня Пыжи\n(Кировская обл.)", systemImage: "house.lodge", coordinate: .village)
                //                    .tint(.gray)
            }
            .foregroundStyle(.white)
            .mapStyle(.standard(elevation: .realistic))
            //#if !os(watchOS)
            //            .sheet {
            //                MapList()
            //                    .environment(map)
            //            .safeAreaInset(edge: .bottom) {
            //                HStack {
            //                    Spacer()
            //
            //                    Button("Reset") {
            //                        withAnimation {
            //                            map.searchResults = places
            //                            map.position = .automatic
            //                        }
            //                    }
            //
            //                    Button {
            //                        map.search(for: "Biscuits N' porn")
            //                    } label: {
            //                        Image(systemName: "cup.and.saucer")
            //                            .title2(.semibold)
            //                            .padding(10)
            //                            .background(.blue, in: .rect(cornerRadius: 16))
            //                            .foregroundStyle(.white)
            //                    }
            //
            //                    Spacer()
            //                }
            //                .padding(.vertical)
            //                .background(.ultraThinMaterial)
            //            }
            //#endif
        }
        .onAppear {
            map.searchResults = places
        }
        .onChange(of: map.searchResults) {
            withAnimation {
                map.position = .automatic
            }
        }
        //#if os(watchOS)
        //        .overlay(alignment: .bottomTrailing) {
        //            SFButton("list.bullet") {
        //                sheetList = true
        //            }
        //            .clipShape(.circle)
        //            .frame(width: 32, height: 32)
        //            .padding(20)
        //        }
        //#else
        //        .toolbar {
        //            SFButton("list.bullet") {
        //                sheetList = true
        //            }
        //        }
        //#endif
        .ignoresSafeArea()
#if !os(macOS)
        .toolbarBackground(.visible, for: .navigationBar)
#endif
        .onChange(of: map.region.span.latitudeDelta) { _, newValue in
            withAnimation {
                showName = newValue < 16
            }
        }
    }
}

#Preview {
    MapView()
}
