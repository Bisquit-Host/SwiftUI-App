import SwiftUI
import PteroNet

struct InfoTabCard: View {
    @EnvironmentObject private var settings: ValueStorage
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text(server.name)
                            .title3(.semibold)
                            .animation(.default, value: server.name)
                        
                        Text(server.node)
                            .footnote()
                            .offset(y: -1)
                            .foregroundStyle(.tertiary)
                    }
                    
                    Text(server.description)
                        .footnote()
                        .lineLimit(2)
                        .animation(.default, value: server.description)
                }
                
                Spacer()
                
                PowerSwitch()
            }
            
            TabView(selection: $settings.lastInfoTab) {
                InfoRelativeStats(server.limits)
                    .tag(TabInfo.relative)
                
                InfoAbsoluteStats(server.limits)
                    .tag(TabInfo.absolute)
                
                InfoTabAllocation(server)
                    .tag(TabInfo.ip)
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
    InfoTabCard(
        sampleJSON(.serverListAttributes)
    )
    .environment(PanelVM(""))
    .environmentObject(ValueStorage())
}
