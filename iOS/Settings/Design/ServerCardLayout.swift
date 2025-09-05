import SwiftUI

struct ServerCardLayout: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            Section("Tap to select a layout") {
                Button {
                    store.compactServerList = false
                } label: {
                    ServerCard(PreviewProp.serverAttributes)
                }
                .padding(5)
                .background(store.compactServerList ? .gray : .blue, in: .rect(cornerRadius: 18))
                .padding(.bottom, -8)
                
                Button {
                    store.compactServerList = true
                } label: {
                    HStack {
                        CompactServerCard(PreviewProp.serverAttributes)
                        CompactServerCard(PreviewProp.serverAttributes)
                    }
                }
                .padding(5)
                .background(store.compactServerList ? .blue : .gray, in: .rect(cornerRadius: 16))
                .padding(.top, -8)
            }
            .foregroundStyle(.foreground)
            .listRowSeparator(.hidden)
            
            Section {
                Toggle("Description", isOn: $store.serverCardDescription)
                    .disabled(store.compactServerList)
                // .disabled doesn't change label's color
                    .foregroundStyle(store.compactServerList ? .tertiary : .primary)
            }
        }
        .navigationTitle("Server Card layout")
    }
}

#Preview {
    NavigationStack {
        ServerCardLayout()
    }
    .environmentObject(ValueStore())
}
