import SwiftUI
import MapKit
import Kingfisher
import Observation

struct MapView: View {
    @Environment(\.displayScale) private var displayScale
    
    private let isMoscow: Bool
    
    init(_ isMoscow: Bool) {
        self.isMoscow = isMoscow
    }
    
    @State private var vm = MapViewVM()
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            
            ZStack {
                if let snapshot = vm.snapshot {
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
                vm.updateSnapshotWidth(width, displayScale: displayScale)
            }
            .onChange(of: width) { _, newWidth in
                vm.updateSnapshotWidth(newWidth, displayScale: displayScale)
            }
        }
        .frame(maxWidth: .infinity, minHeight: vm.mapHeight, maxHeight: vm.mapHeight)
        .clipShape(.rect(topLeadingCorner: 0, topTrailingCorner: 0, bottomLeadingCorner: 12, bottomTrailingCorner: 12))
        .onFirstAppear {
            vm.updateRegion(isMoscow: isMoscow, displayScale: displayScale)
        }
        .onChange(of: isMoscow) {
            vm.updateRegion(isMoscow: isMoscow, displayScale: displayScale)
        }
    }
}
