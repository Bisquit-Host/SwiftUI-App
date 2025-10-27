import SwiftUI

struct SubdomainList: View {
    @Environment(SubdomainVM.self) private var vm
    
    @State private var sheetCreate = false
    
    private var disabled: Bool {
        vm.subdomains.count >= vm.limit
    }
    
    var body: some View {
        List {
            ForEach(vm.subdomains) {
                SubdomainCard($0)
                    .listRowSeparator(.hidden)
            }
            .onDelete(perform: delete)
            
            Section {
                Button {
                    sheetCreate = true
                } label: {
                    Image(systemName: "link.badge.plus")
                        .foregroundStyle(.foreground)
                        .bold()
                        .frame(30)
                        .background(.ultraThinMaterial.opacity(0.3), in: .circle)
                        .overlay {
                            Circle()
                                .stroke(.gray.opacity(0.25), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
        }
        .navigationTitle("Subdomains")
        .scrollIndicators(.never)
        .scrollContentBackground(.hidden)
        .refreshableTask {
            await vm.fetchSubdomains()
        }
        .sheet($sheetCreate) {
            SheetCreateSubdomain()
                .frame(minHeight: StatRows.minHeight)
        }
        .overlay {
            if vm.subdomains.isEmpty {
                ContentUnavailableView(
                    "No subdomains have been created yet",
                    systemImage: "link.badge.plus",
                    description: Text("Use the button in the top right corner to create one")
                )
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let subdomain = vm.subdomains[index]
            
            Task {
                await vm.deleteSubdomain(subdomain.id)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SubdomainList()
    }
    .darkSchemePreferred()
    .environment(SubdomainVM(""))
}
