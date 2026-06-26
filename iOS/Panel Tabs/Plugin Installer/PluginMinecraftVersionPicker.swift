import SwiftUI

struct PluginMinecraftVersionPicker: View {
    @Environment(PluginInstallerVM.self) private var vm
    
    @Binding var version: String
    
    var body: some View {
        HStack {
            Text("Minecraft version")
            
            Spacer()
            
            Picker("Minecraft version", selection: $version) {
                Text("Any")
                    .tag("")
                
                ForEach(vm.versionOptions, id: \.self) { version in
                    Text(version)
                        .tag(version)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
        }
    }
}
