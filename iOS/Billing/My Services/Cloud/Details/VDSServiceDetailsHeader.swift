import SwiftUI

struct VDSServiceDetailsHeader: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let service: CloudServiceDetails?
    
    init(_ service: CloudServiceDetails?) {
        self.service = service
    }
    
    @State private var showVNC = false
    
    var body: some View {
        HStack(spacing: 10) {
            Button("Console", systemImage: "display") {
                showVNC = true
            }
            .footnote()
#if !os(visionOS)
            .foregroundStyle(service == nil ? Color.secondary : .blue)
#else
            .foregroundStyle(service == nil ? Color.secondary : .primary)
#endif
        }
        .disabled(service == nil)
        .animation(store.bigAssAnimations && !reduceMotion ? .smooth : nil, value: service != nil)
        .safariCover($showVNC, url: service.map { "https://my.bisquit.host/cloud/\($0.id)?tab=console" } ?? "")
    }
}
