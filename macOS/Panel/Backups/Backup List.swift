import SwiftUI

struct BackupList: View {
    @State private var vm: BackupVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = BackupVM(id)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(vm.backups, id: \.uuid) { backup in
                    BackupCard(backup)
                }
            }
        }
        .environment(vm)
        .navigationTitle("Backups")
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .task {
            vm.fetchBackups()
        }
        .onChange(of: id) {
            vm.fetchBackups()
        }
    }
}

#Preview {
    BackupList("")
}
