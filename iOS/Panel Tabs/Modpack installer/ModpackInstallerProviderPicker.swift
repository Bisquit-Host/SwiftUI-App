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
                    Label($0.name, image: $0.img)
                        .tag($0)
                }
            } currentValueLabel: {
                Text(selectedProvider.name)
            }
            .tint(.primary)
        }
    }
}
