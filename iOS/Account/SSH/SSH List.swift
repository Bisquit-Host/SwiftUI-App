import ScrechKit

struct SSHList: View {
    @Environment(SSHVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var sheetCreate = false
    
    var body: some View {
        List {
            Section {
                ForEach(vm.keys, id: \.name) { key in
                    SSHCard(key)
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationTitle("SSH")
        .scrollContentBackground(.hidden)
        .refreshableTask {
            await vm.fetchKeys()
        }
        .sheet($sheetCreate) {
            SSHCreateView()
        }
        .overlay {
            if vm.keys.isEmpty {
                ContentUnavailableView(
                    "No SSH-keys have been created yet",
                    systemImage: "link.badge.plus",
                    description: Text("Use the button in the top right corner to create one")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissButton {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                SFButton("plus") {
                    sheetCreate = true
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        offsets.forEach { index in
            let key = vm.keys[index].fingerprint
            
            Task {
                await vm.deleteKey(key)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SSHList()
    }
    .environment(SSHVM())
}
