import SwiftUI

struct SSHList: View {
    @Environment(SSHVM.self) private var vm
    
    @State private var sheetCreate = false
    
    var body: some View {
        List {
            ForEach(vm.keys, id: \.name) { key in
                SSHCard(key)
            }
            .onDelete(perform: deleteItems)
            
            Section {
                Button("Create") {
                    sheetCreate = true
                }
            }
            .transparentSection()
        }
        .navigationTitle("SSH")
        .transparentList()
        .refreshableTask {
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
        .environment(SSHVM())
}
