import SwiftUI

struct AccountRemovalSection: View {
    @State private var vm = TicketListVM()
    
    var body: some View {
        @Bindable var vm = vm
        
        BillingSectionCard {
            GlassyActionCard("Request account removal", icon: "person.crop.circle.badge.minus", tint: .red, role: .destructive) {
                requestAccountRemoval()
            }
        }
        .alert("Too many open tickets", isPresented: $vm.alertTooManyTickets) {
            Button("Okay") {}
        } message: {
            Text("You already have 2 open tickets")
        }
        .sheet($vm.showCreateSheet) {
            NavigationStack {
                CreateTicketSheet(.accountRemoval)
                    .environment(vm)
            }
        }
    }
    
    private func requestAccountRemoval() {
        Task {
            await vm.fetchTickets()
            vm.createNewTicket()
        }
    }
}
