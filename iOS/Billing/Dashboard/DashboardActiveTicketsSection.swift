import SwiftUI

struct DashboardActiveTicketsSection: View {
    @State private var vm = TicketListVM()
    
    var body: some View {
        Group {
            if !vm.tickets.isEmpty {
                BillingSectionCard("Active tickets", showsBackground: false) {
                    VStack(spacing: 12) {
                        ForEach(vm.tickets) {
                            TicketCard($0, vm: vm)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                                .foregroundStyle(.primary)
                        }
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
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
