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
            
            Button("Create") {
                create()
            }
            .disabled(vm.newName.isEmpty || vm.newPublicKey.isEmpty)
        }
    }
    
    private func create() {
        Task {
            await vm.createKey() {
                dismiss()
            }
        }
    }
}

#Preview {
    SSHCreateView()
        .darkSchemePreferred()
        .environment(SSHVM())
}
