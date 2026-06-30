import SwiftUI
import Calagopus

struct ModpackInstallerSearchSection: View {
    @EnvironmentObject private var store: ValueStore
    
    @Binding var selectedProvider: ModpackProvider
    @Binding var searchQuery: String
    
    let reloadModpacks: () -> Void
    
    var body: some View {
        BillingSectionCard(showsBackground: false) {
            TextField("Search", text: $searchQuery)
                .panelSearchField()
                .disabled(selectedProvider == .voidswrath)
                .submitLabel(.search)
                .onSubmit(reloadModpacks)
            
            ModpackInstallerProviderPicker($selectedProvider)
        }
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
    }
}
