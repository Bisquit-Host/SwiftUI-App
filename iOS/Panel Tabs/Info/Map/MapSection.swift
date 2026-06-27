import SwiftUI
import Calagopus
import SafariCover

struct MapSection: View {
    @EnvironmentObject private var store: ValueStore
    
    private let server: CalagopusServer
    private let node: String
    private let allocations: [CalagopusServerAllocation]
    
    init(_ server: CalagopusServer) {
        self.server = server
        node = server.nodeName
        allocations = server.allocation.map { [$0] } ?? []
    }
    
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
                    
                    Text(isMoscow ? String(localized: "Moscow, Russia") : String(localized: "Frankfurt, Germany"))
                        .semibold()
                        .rounded()
                }
                
                Spacer()
                
                MapSectionPing(allocations)
            }
            .frame(height: 80)
            .padding(.horizontal)
            .offset(y: 5)
            
            MapView(isMoscow)
        }
        .contentShape(.rect)
        .foregroundStyle(.foreground)
        .clipShape(.rect(cornerRadius: 16))
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
        .frame(height: 250)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
        .contextMenu {
            Button("Open in Apple Maps", image: .maps) {
                openSafari(mapURL)
            }
        }
    }
}

#Preview {
    MapSection(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
