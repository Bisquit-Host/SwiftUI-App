import SwiftUI

struct ModManagerMinecraftVersionPicker: View {
    @Environment(ModInstallerVM.self) private var vm
    
    @Binding private var version: String
    
    init(_ version: Binding<String>) {
        _version = version
    }
    
    var body: some View {
        HStack {
            Text("Minecraft version")
            
            Spacer()
            
            Picker("Minecraft version", selection: $version) {
                Text("Any")
                    .tag("")
                
                ForEach(vm.versionOptions, id: \.self) { option in
                    Text(option)
                        .tag(option)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
        }
    }
}

#Preview {
    ModManagerMinecraftVersionPicker(.constant(""))
        .padding()
        .environment(ModInstallerVM(""))
}
