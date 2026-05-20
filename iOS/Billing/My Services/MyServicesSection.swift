import SwiftUI

struct MyServicesSection<Detail: View>: View {
    let title: LocalizedStringKey
    let services: [BillingMyService]
    let isLoading: Bool
    let detail: (BillingMyService) -> Detail
    
    init(
        title: LocalizedStringKey,
        services: [BillingMyService],
        isLoading: Bool,
        @ViewBuilder detail: @escaping (BillingMyService) -> Detail
    ) {
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
                ForEach(services, id: \.listID) { item in
                    NavigationLink {
                        detail(item)
                    } label: {
                        MyServiceCard(item)
                    }
                }
            }
        }
    }
}
