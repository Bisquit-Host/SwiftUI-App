import SwiftUI

struct DashboardActiveTicketsSection: View {
    @Environment(TicketListVM.self) private var vm
    
    var body: some View {
        Group {
            if !vm.tickets.isEmpty {
                BillingSectionCard("Active tickets", showsBackground: false) {
                    ForEach(vm.tickets) {
                        TicketCard($0, vm: vm)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .dashboardButtonCardBackground()
                            .foregroundStyle(.primary)
                            .buttonStyle(.plain)
                    }
                }
            }
        }
        .task {
            await reload()
        }
        .task {
            for await _ in NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification) {
                await reload()
            }
        }
    }
    
    private func reload() async {
        vm.showClosed = false
        await vm.fetchTickets()
    }
}

#Preview {
    NavigationStack {
        DashboardActiveTicketsSection()
    }
    .environment(TicketListVM())
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
