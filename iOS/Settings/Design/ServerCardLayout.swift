import SwiftUI

struct ServerCardLayout: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    var body: some View {
        List {
            Section("Tap to select a layout") {
                Button {
                    store.compactServerList = false
                } label: {
                    if differentiateWithoutColor, !store.compactServerList {
                        Text("Selected")
                            .semibold()
                    }
                    
                    ServerCardWide(PreviewProp.serverAttributes)
                }
                .padding(5)
                .background(store.compactServerList ? .gray : .blue, in: .rect(cornerRadius: 18))
                .padding(.bottom, -8)
                
                Button {
                    store.compactServerList = true
                } label: {
                    if differentiateWithoutColor, store.compactServerList {
                        Text("Selected")
                            .semibold()
                    }
                    
                    HStack {
                        ServerCardCompact(PreviewProp.serverAttributes)
                        ServerCardCompact(PreviewProp.serverAttributes)
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
                    .foregroundStyle(store.compactServerList ? .tertiary : .primary) // .disabled doesn't change label's color
            }
        }
        .navigationTitle("Server card layout")
    }
}

#Preview {
    NavigationStack {
        ServerCardLayout()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
