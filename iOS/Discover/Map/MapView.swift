import ScrechKit
import MapKit

struct MapView: View {
    @Bindable private var map = MapVM()
    
    @State private var showName = false
    //    @State private var sheetList = false
    
    var body: some View {
        VStack {
            Map(position: $map.position) {
                ForEach(map.places, id: \.id) {
                    Marker($0.name.key, coordinate: .init(
                        latitude: $0.latitude,
                        longitude: $0.longitude
                    ))
                }
            }
            .foregroundStyle(.white)
            .mapStyle(.standard(elevation: .realistic))
        }
        //#if os(watchOS)
        //        .overlay(alignment: .bottomTrailing) {
        //            SFButton("list.bullet") {
        //                sheetList = true
        //            }
        //            .clipShape(.circle)
        //            .frame(32)
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
        .onChange(of: map.region.span.latitudeDelta) { _, newValue in
            withAnimation {
                showName = newValue < 16
            }
        }
    }
}

#Preview {
    MapView()
        .darkSchemePreferred()
}
