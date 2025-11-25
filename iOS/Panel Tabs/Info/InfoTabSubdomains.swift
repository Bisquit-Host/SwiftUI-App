import SwiftUI
import PteroNet

struct InfoTabSubdomains: View {
    @State private var vm: SubdomainVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        vm = SubdomainVM(server.id)
    }
    
    @State private var sheetSubdomains = false
    @State private var sheetCreate = false
    
    private var allocations: [AllocationAttributes] {
        server.relationships.allocations.data.map(\.attributes)
    }
    
    var body: some View {
        Button {
            sheetSubdomains = true
        } label: {
            HStack {
                if vm.subdomains.isEmpty {
                    VStack(spacing: 5) {
                        Image(systemName: "globe")
                            .tertiary()
                        
                        Text("Subdomains")
                            .semibold()
                    }
                } else {
                    VStack(alignment: .leading) {
                        Text("Subdomains")
                            .footnote(design: .rounded)
                            .secondary()
                        
                        ForEach(vm.subdomains) {
                            Text($0.subdomain + "." + $0.domain)
                                .monospaced()
                        }
                    }
                    
                    Spacer()
                    
                    let chevron = Image(systemName: "arrow.right")
                    
                    Text("All subdomains \(chevron)")
                        .caption2()
                        .tertiary()
                }
            }
            .footnote()
            .frame(minHeight: 55)
            .padding()
            .frame(maxWidth: .infinity, alignment: vm.subdomains.isEmpty ? .center : .leading)
            .foregroundStyle(.foreground)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.gray.opacity(0.25), lineWidth: 1)
            }
        }
        .task {
            await vm.fetchSubdomains()
        }
        .sheet($sheetCreate) {
            SheetCreateSubdomain(allocations)
        }
        .sheet($sheetSubdomains) {
            NavigationStack {
                SubdomainList(allocations)
            }
            .environment(vm)
        }
        .contextMenu {
            Button("Create subdomain", systemImage: "plus") {
                sheetCreate = true
            }
        }
    }
}

#Preview {
    InfoTabSubdomains(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(SubdomainVM(""))
}
