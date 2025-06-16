import SwiftUI

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
        .refreshableTask {
            await vm.fetchKeys()
        }
        .sheet($sheetCreate) {
            SSHCreateView()
        }
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
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
                Button {
                    sheetCreate = true
                } label: {
                    Image(systemName: "plus")
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
    SSHList()
        .environment(SSHVM())
}
