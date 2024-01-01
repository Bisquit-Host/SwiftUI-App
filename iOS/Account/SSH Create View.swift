import SwiftUI

struct SSHCreateView: View {
    @Environment(SSHVM.self) private var vm
    
    @State private var name = ""
    @State private var publicKey = ""
    
    var body: some View {
        List {
            TextField("Name", text: $name)
            
            TextEditor(text: $publicKey)
            
            Section {
                Button("Create") {
                    vm.createKey(name, publicKey: publicKey)
                }
                .disabled(name.isEmpty || publicKey.isEmpty)
            }
        }
    }
}

#Preview {
    SSHCreateView()
}
