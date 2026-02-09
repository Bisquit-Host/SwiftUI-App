import SwiftUI

struct PluginProviderPickerSection: View {
    @Binding var selectedProvider: PluginProvider
    
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
