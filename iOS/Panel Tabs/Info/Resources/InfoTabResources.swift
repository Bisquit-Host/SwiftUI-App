import SwiftUI
import PteroNet

struct InfoTabResources: View {
    @EnvironmentObject private var store: ValueStore
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        TabView(selection: $store.lastInfoTab) {
            InfoRelativeStats(server.limits)
                .tag(TabInfo.relative)
            
            InfoAbsoluteStats(server.limits)
                .tag(TabInfo.absolute)
        }
        .frame(height: 120)
        .padding(.vertical, -20)
        .tabViewStyle(.page)
        .padding([.horizontal, .bottom])
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
    }
}

#Preview {
    InfoTabResources(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
