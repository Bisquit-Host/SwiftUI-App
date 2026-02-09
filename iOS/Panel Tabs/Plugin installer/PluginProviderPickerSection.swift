import SwiftUI

struct PluginProviderPickerSection: View {
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
                    Text($0.name)
                        .tag($0)
                }
            }
            .tint(.primary)
        }
    }
}
