import SwiftUI

struct ModManagerLoaderPicker: View {
    @Environment(ModInstallerVM.self) private var vm
    
    @Binding private var modLoader: String
    
    init(_ modLoader: Binding<String>) {
        _modLoader = modLoader
    }
    
    private let fallbackLoaders = [
        "fabric", "forge", "neoforge", "quilt"
    ]
    
    var body: some View {
        HStack {
            Text("Mod loader")
            
            Spacer()
            
            Picker("Mod loader", selection: $modLoader) {
                Text("All")
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
            fallbackLoaders
        } else {
            vm.modLoaderOptions
        }
    }
}

#Preview {
    ModManagerLoaderPicker(.constant(""))
        .padding()
        .environment(ModInstallerVM(""))
}
