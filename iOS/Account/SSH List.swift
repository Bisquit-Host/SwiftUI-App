import SwiftUI

struct SSHList: View {
    @Environment(SSHVM.self) private var vm
    
    @State private var sheetCreate = false
    
    var body: some View {
        ForEach(vm.keys, id: \.name) { key in
            SSHCard(key)
        }
        .onDelete(perform: deleteItems)
        
        Section {
            Button("Create") {
                sheetCreate = true
            }
        }
        .task {
            vm.fetchKeys()
        }
        .sheet($sheetCreate) {
            SSHCreateView()
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        offsets.forEach { index in
            vm.deleteKey(vm.keys[index].fingerprint)
        }
    }
}

#Preview {
    SSHList()
}
