import ScrechKit
import SafariCover

struct Discover: View {
    private var vm = DiscoverVM()
    
    @State private var sheetBrowsePlans = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ListButton("Configure a new server", actionIcon: "externaldrive.badge.plus") {
                        sheetBrowsePlans = true
                    }
                    .foregroundStyle(.foreground)
                }
                
                ForEach(Array(vm.sections), id: \.0) { section, items in
                    Section(section) {
                        ForEach(items, id: \.name) { link in
                            DiscoverCard(link)
                        }
                    }
                }
                
                NavigationLink {
                    MapView()
                } label: {
                    ListButton("Locations (unofficial)", icon: "map")
                }
            }
        }
        .sheet($sheetBrowsePlans) {
            Browser()
        }
    }
}

#Preview {
    Discover()
}
