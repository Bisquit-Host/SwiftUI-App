import ScrechKit
import UniformTypeIdentifiers

struct SSHCreateView: View {
    @Environment(SSHVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var publicKey = ""
    @State private var isTargeted = false
    
    var body: some View {
        List {
            Section {
                TextField("Name", text: $name)
                
                TextEditor(text: $publicKey)
                    .onDrop(of: [.text], isTargeted: $isTargeted) { providers in
                        handleDrop(providers: providers)
                        return true
                    }
                    .frame(minHeight: 200)
                    .overlay {
                        if isTargeted {
                            VStack {
                                Image(systemName: "plus")
                                
                                Text("Drop here")
                            }
                            .title(.semibold)
                            .foregroundStyle(.green)
                        }
                    }
            } footer: {
                Text("Enter or drag-and-drop your public SSH-key")
            }
            
            Button("Create") {
                vm.createKey(name, publicKey: publicKey) {
                    dismiss()
                }
            }
            .disabled(name.isEmpty || publicKey.isEmpty)
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.text") {
                provider.loadDataRepresentation(forTypeIdentifier: "public.text") { data, error in
                    if let data, let fileContent = String(data: data, encoding: .utf8) {
                        main {
                            if let name = provider.suggestedName {
                                self.name = name
                            }
                            
                            self.publicKey = fileContent
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SSHCreateView()
}
