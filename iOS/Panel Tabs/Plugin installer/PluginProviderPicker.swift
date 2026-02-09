import SwiftUI

struct PluginProviderPicker: View {
    @Binding private var selectedProvider: PluginProvider
    
    init(_ selectedProvider: Binding<PluginProvider>) {
        _selectedProvider = selectedProvider
    }
    
    var body: some View {
        HStack {
            Text("Provider")
            
            Spacer()
            
            Picker("Provider", selection: $selectedProvider) {
                ForEach(PluginProvider.allCases) {
                    providerLabel($0)
                        .tag($0)
                }
            } currentValueLabel: {
                Text(selectedProvider.name)
            }
            .tint(.primary)
        }
    }
    
    @ViewBuilder
    private func providerLabel(_ provider: PluginProvider) -> some View {
        switch provider {
        case .curseforge:
            Label(provider.name, image: .curseForge)
            
        case .modrinth:
            Label(provider.name, image: .modrinth)
            
        case .hangar, .spigotmc, .polymart:
            Text(provider.name)
        }
    }
}
