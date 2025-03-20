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
            .transparentSection()
        }
        .navigationTitle("SSH")
        .toolbarBackground(.visible, for: .tabBar)
        .transparentList()
        .refreshableTask {
            vm.fetchKeys()
        }
        .sheet($sheetCreate) {
            SSHCreateView()
        }
        .background {
            Image(.darkBackgroundInfo)
                .resizable()
                .blur(radius: 55, opaque: true)
                .ignoresSafeArea()
        }
        .scrollContentBackground(.hidden)
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
                        .foregroundStyle(.foreground)
                        .footnote(.bold)
                        .frame(width: 35, height: 35)
                        .background(.ultraThinMaterial, in: .circle)
                }
            }
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
