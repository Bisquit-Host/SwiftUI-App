import SwiftUI

struct PluginMinecraftVersionPicker: View {
    @Binding var version: String
    
    let versionOptions: [String]
    
    var body: some View {
        HStack {
            Text("Minecraft version")
            
            Spacer()
            
            Picker("Minecraft version", selection: $version) {
                Text("Any")
                    .tag("")
                
                ForEach(versionOptions, id: \.self) { version in
                    Text(version)
                        .tag(version)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
        }
    }
}
