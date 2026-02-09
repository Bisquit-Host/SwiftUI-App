import SwiftUI

struct ModManagerProviderPicker: View {
    @Binding var selectedProvider: ModManagerProvider
    
    var body: some View {
        Picker("Provider", selection: $selectedProvider) {
            ForEach(ModManagerProvider.allCases) {
                Text($0.name)
                    .tag($0)
            }
        }
        .pickerStyle(.segmented)
        .tint(.primary)
    }
}

#Preview {
    ModManagerProviderPicker(selectedProvider: .constant(.modrinth))
        .padding()
}
