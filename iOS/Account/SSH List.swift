import SwiftUI

struct SSHList: View {
    private var vm = SSHVM()
    
    @State private var sheetCreate = false
        
    var body: some View {
        Section {
            ForEach(vm.keys, id: \.name) { key in
                SSHCard(key)
            }
            
            Section {
                Button("Create") {
                    sheetCreate = true
                }
            }
        } header: {
            Text("SSH Keys")
        }
        .task {
            vm.fetchKeys()
        }
        .sheet($sheetCreate) {
            SSHCreateView()
                .environment(vm)
        }
    }
}

#Preview {
    SSHList()
}
