import SwiftUI

struct ModManagerLoaderPicker: View {
    @Environment(ModInstallerVM.self) private var vm
    
    @Binding var modLoader: String
    
    private let fallbackLoaders = [
        "fabric", "forge", "neoforge", "quilt"
    ]
    
    var body: some View {
        HStack {
            Text("Mod loader")
            
            Spacer()
            
            Picker("Mod loader", selection: $modLoader) {
                Text("Any")
                    .tag("")
                
                ForEach(displayedModLoaders, id: \.self) { loader in
                    Text(loader.capitalized)
                        .tag(loader)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
        }
    }
    
    private var displayedModLoaders: [String] {
        if vm.modLoaderOptions.isEmpty {
            return fallbackLoaders
        }
        
        return vm.modLoaderOptions
    }
}

#Preview {
    ModManagerLoaderPicker(modLoader: .constant(""))
        .padding()
        .environment(ModInstallerVM(""))
}
