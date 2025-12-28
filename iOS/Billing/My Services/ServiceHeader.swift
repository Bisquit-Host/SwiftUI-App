import SwiftUI

struct ServiceHeader: View {
    private let service: BillingServiceDetails
    
    init(_ service: BillingServiceDetails) {
        self.service = service
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Text(service.name)
                    .title3(.bold)
                
                Spacer()
                
                Capsule()
                    .fill(service.state.color.opacity(0.15))
                    .overlay {
                        Text(service.state.title)
                            .footnote(.semibold)
                            .foregroundStyle(service.state.color)
                            .padding(.horizontal, 10)
                    }
                    .frame(height: 30)
            }
            
            HStack(spacing: 10) {
                Text(service.packageInfo.name)
                    .footnote()
                    .secondary()
                
                FlagIcon(service.location.flagUrl)
                
                Text(service.location.name)
                    .footnote()
                    .secondary()
            }
        }
    }
}
