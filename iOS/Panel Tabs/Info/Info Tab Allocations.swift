import SwiftUI
import PteroNet

struct InfoTabSubdomains: View {
    @Environment(SubdomainVM.self) private var vm
    
    private let allocations: [AllocationAttributes]
    
    init(_ allocations: [AllocationAttributes]) {
        self.allocations = allocations
    }
    
    @State private var sheetSubdomains = false
    
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
                            .footnote()
                            .secondary()
                            .rounded()
                        
                        ForEach(vm.subdomains) { subdomain in
                            Text("\(subdomain.subdomain).\(subdomain.domain)")
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
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: vm.subdomains.isEmpty ? .center : .leading)
            .foregroundStyle(.foreground)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.gray.opacity(0.25), lineWidth: 1)
            }
        }
        .sheet($sheetSubdomains) {
            NavigationView {
                SubdomainList(allocations)
            }
            .environment(vm)
        }
    }
}
