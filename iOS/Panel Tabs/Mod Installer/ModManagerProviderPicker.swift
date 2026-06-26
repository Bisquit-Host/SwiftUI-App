import Calagopus
import SwiftUI

struct ModManagerProviderPicker: View {
    @Binding private var selectedProvider: ModManagerProvider
    
    init(_ selectedProvider: Binding<ModManagerProvider>) {
        _selectedProvider = selectedProvider
    }
    
    var body: some View {
        HStack {
            Text("Provider")
            
            Spacer()
            
            Picker("Provider", selection: $selectedProvider) {
                ForEach(ModManagerProvider.allCases) {
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

#Preview {
    ModManagerProviderPicker(.constant(.modrinth))
        .padding()
}
