import SwiftUI

struct BillingMyServiceDestinationView: View {
    @Environment(DashboardVM.self) private var vm
    
    let service: BillingMyService
    
    var body: some View {
        switch service {
        case .cloud(let service):
            VDSServiceDetailsTab(service)
                .environment(vm)
            
        case .game(let service):
            ServiceDetailsView<GameServiceDetailsVM>(service)
                .environment(vm)
            
        case .bot(let service):
            ServiceDetailsView<BotServiceDetailsVM>(service)
                .environment(vm)
        }
    }
}
