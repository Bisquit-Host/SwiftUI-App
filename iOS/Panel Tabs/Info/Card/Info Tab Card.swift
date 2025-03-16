import SwiftUI
import PteroNet

struct InfoTabCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TabView(selection: $store.lastInfoTab) {
                InfoRelativeStats(server.limits)
                    .tag(TabInfo.relative)
                
                InfoAbsoluteStats(server.limits)
                    .tag(TabInfo.absolute)
            }
            .frame(height: 120)
            .padding(.vertical, -20)
            .tabViewStyle(.page)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
    }
}

#Preview {
    InfoTabCard(sampleJSON(.serverListAttributes))
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
