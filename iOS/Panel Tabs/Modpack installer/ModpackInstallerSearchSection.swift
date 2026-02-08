import SwiftUI

struct ModpackInstallerSearchSection: View {
    @Environment(ModpackInstallerVM.self) private var vm
    
    @Binding var selectedProvider: ModpackProvider
    @Binding var searchQuery: String
    
    let reloadModpacks: () -> Void
    
    var body: some View {
        BillingSectionCard("Search") {
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
    }
}
