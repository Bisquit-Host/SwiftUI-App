import SwiftUI
import UniformTypeIdentifiers

struct SSHCreateView: View {
    @Environment(SSHVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isTargeted = false
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section {
                TextField("Name", text: $vm.newName)
                
                TextEditor(text: $vm.newPublicKey)
                    .onDrop(of: [.text], isTargeted: $isTargeted) { providers in
                        vm.handleDrop(providers)
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
            .transparentSection()
            
            Button("Create") {
                Task {
                    await vm.createKey() {
                        dismiss()
                    }
                }
            }
            .disabled(vm.newName.isEmpty || vm.newPublicKey.isEmpty)
            .transparentSection()
        }
        .transparentList()
    }
}

#Preview {
    SSHCreateView()
}
