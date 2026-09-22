import SwiftUI

struct BillingMyServiceDestinationView: View {
    @Environment(DashboardVM.self) private var vm
    
    private let service: BillingMyService
    
    init(_ service: BillingMyService) {
        self.service = service
    }
    
    var body: some View {
        switch service {
        case .cloud(let service):
            VDSServiceDetailsTab(
                service.id,
                name: service.name,
                packageName: service.packageName,
                locationName: service.locationName
            )
            .environment(vm)
            
        case .game(let service):
            ServiceDetailsView<GameServiceDetailsVM>(
                service.id,
                name: service.name,
                packageName: service.packageName,
                locationName: service.locationName
            )
            .environment(vm)
            
        case .bot(let service):
            ServiceDetailsView<BotServiceDetailsVM>(
                service.id,
                name: service.name,
                packageName: service.packageName,
                locationName: service.locationName
            )
            .environment(vm)
        }
    }
}
