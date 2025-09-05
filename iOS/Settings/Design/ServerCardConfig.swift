import SwiftUI

struct ServerCardConfig: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var serverCardDescription = true
    @State private var liquidGlassBackground = true
    
    var body: some View {
        List {
            Section {
                Button {
                    store.compactServerList = true
                } label: {
                    ServerCard(PreviewProp.serverAttributes)
                }
                .padding(5)
                .background(store.compactServerList ? .blue : .clear, in: .rect(cornerRadius: 16))
                
                Button {
                    store.compactServerList = false
                } label: {
                    HStack {
                        CompactServerCard(PreviewProp.serverAttributes)
                        CompactServerCard(PreviewProp.serverAttributes)
                    }
                }
                .padding(5)
                .background(store.compactServerList ? .clear : .blue, in: .rect(cornerRadius: 16))
            }
            .foregroundStyle(.foreground)
            .listRowSeparator(.hidden)
            
            Section {
                Toggle("Description", isOn: $serverCardDescription)
                    .disabled(store.compactServerList)
                // .disabled doesn't change label's color
                    .foregroundStyle(store.compactServerList ? .tertiary : .primary)
                
                Toggle("Liquid Glass Background", isOn: $liquidGlassBackground)
                
            }
        }
    }
}

#Preview {
    ServerCardConfig()
        .environmentObject(ValueStore())
}
