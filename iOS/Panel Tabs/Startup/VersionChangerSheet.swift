import SwiftUI

struct VersionChangerSheet: View {
    @Environment(StartupVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let serverUUID: String
    
    init(serverUUID: String) {
        self.serverUUID = serverUUID
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    BillingSectionCard("Status") {
                        VersionChangerStatusSection()
                    }
                    
                    BillingSectionCard("Available versions") {
                        VersionChangerTypeListSection()
                    }
                }
                .padding()
            }
            .scrollIndicators(.never)
            .navigationTitle("Version Changer")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                vm.setVersionChangerServerId(serverUUID)
                await vm.fetchVersionChangerData()
            }
        }
    }
}

#Preview {
    VersionChangerSheet(serverUUID: "")
        .darkSchemePreferred()
        .environment(StartupVM(""))
}
