import SwiftUI

struct BillingMyServicesSection<Detail: View>: View {
    let title: LocalizedStringKey
    let services: [BillingMyService]
    let isLoading: Bool
    let detail: (Int) -> Detail
    
    init(_ title: LocalizedStringKey, services: [BillingMyService], isLoading: Bool, detail: @escaping (Int) -> Detail) {
        self.title = title
        self.services = services
        self.isLoading = isLoading
        self.detail = detail
    }
    
    var body: some View {
        Section(title) {
            if isLoading && services.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            if services.isEmpty && !isLoading {
                Text("No services yet")
                    .secondary()
                    .footnote()
            } else {
                ForEach(services) { item in
                    NavigationLink {
                        detail(item.id)
                    } label: {
                        BillingServiceRow(item)
                    }
                }
            }
        }
    }
}
