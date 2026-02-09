import SwiftUI

struct ModpackInstallerSearchSection: View {
    @EnvironmentObject private var store: ValueStore
    
    @Binding var selectedProvider: ModpackProvider
    @Binding var searchQuery: String
    
    let reloadModpacks: () -> Void
    
    var body: some View {
        BillingSectionCard(showsBackground: false) {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Search", text: $searchQuery)
                    .panelSearchField()
                    .disabled(selectedProvider == .voidswrath)
                    .submitLabel(.search)
                    .onSubmit(reloadModpacks)
                
                ModpackInstallerProviderPicker(selectedProvider: $selectedProvider)
            }
        }
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
    }
}
