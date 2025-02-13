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
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(server.name)
                        .title3(.semibold)
                        .animation(.default, value: server.name)
                    
                    if !server.description.isEmpty {
                        Text(server.description)
                            .footnote()
                            .lineLimit(2)
                            .animation(.default, value: server.description)
                    }
                    
                    Text("\(server.id) • \(server.node)")
                        .caption2()
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                PowerSwitch()
            }
            
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
    }
}

#Preview {
    InfoTabCard(sampleJSON(.serverListAttributes))
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
