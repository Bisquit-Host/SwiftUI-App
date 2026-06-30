import SwiftUI
import Calagopus

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
