import SwiftUI

struct ModpackInstallerSearchSection: View {
    @EnvironmentObject private var store: ValueStore
    
    @Binding var selectedProvider: ModpackProvider
    @Binding var searchQuery: String
    
    let reloadModpacks: () -> Void
    
    var body: some View {
        BillingSectionCard(showsBackground: false) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Provider")
                    
                    Spacer()
                    
                    Picker("Provider", selection: $selectedProvider) {
                        ForEach(ModpackProvider.allCases) {
                            Text($0.name)
                                .tag($0)
                        }
                    }
                    .tint(.primary)
                }

                TextField("Search", text: $searchQuery)
                    .panelSearchField()
                    .disabled(selectedProvider == .voidswrath)
                    .submitLabel(.search)
                    .onSubmit(reloadModpacks)
            }
        }
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
    }
}
