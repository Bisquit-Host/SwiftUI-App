import SwiftUI

struct ModpackInstallerSearchSection: View {
    @Environment(ModpackInstallerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @Binding var selectedProvider: ModpackProvider
    @Binding var searchQuery: String
    
    let reloadModpacks: () -> Void
    
    var body: some View {
        BillingSectionCard("Search", showsBackground: false) {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Provider", selection: $selectedProvider) {
                    ForEach(ModpackProvider.allCases) {
                        Text($0.name)
                            .tag($0)
                    }
                }
                .tint(.primary)
                
                TextField("Search", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .disabled(selectedProvider == .voidswrath)
                    .submitLabel(.search)
                    .onSubmit {
                        reloadModpacks()
                    }
                
                Button("Find modpacks", systemImage: "magnifyingglass", action: reloadModpacks)
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isLoadingModpacks)
            }
        }
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
    }
}
