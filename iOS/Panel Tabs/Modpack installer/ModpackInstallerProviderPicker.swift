import SwiftUI

struct ModpackInstallerProviderPicker: View {
    @Binding private var selectedProvider: ModpackProvider
    
    init(_ selectedProvider: Binding<ModpackProvider>) {
        _selectedProvider = selectedProvider
    }
    
    var body: some View {
        HStack {
            Text("Provider")
            
            Spacer()
            
            Picker("Provider", selection: $selectedProvider) {
                ForEach(ModpackProvider.allCases) {
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
    private func providerLabel(_ provider: ModpackProvider) -> some View {
        switch provider {
        case .curseforge:
            Label(provider.name, image: .curseForge)
            
        case .modrinth:
            Label(provider.name, image: .modrinth)
            
        case .feedthebeast:
            Label(provider.name, image: .FTB)
            
        default:
            Text(provider.name)
        }
    }
}
