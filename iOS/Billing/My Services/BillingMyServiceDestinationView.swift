import SwiftUI

struct BillingMyServiceDestinationView: View {
    @Environment(DashboardViewVM.self) private var vm
    
    private let service: BillingMyService
    
    init(_ service: BillingMyService) {
        self.service = service
    }
    
    var body: some View {
        switch service {
        case .cloud(let service):
            VDSServiceDetailsTabView(service.id)
                .environment(vm)
            
        case .game(let service):
            ServiceDetailsView<GameServiceDetailsVM>(service.id)
                .environment(vm)
            
        case .bot(let service):
            ServiceDetailsView<BotServiceDetailsVM>(service.id)
                .environment(vm)
        }
    }
}
