import SwiftUI

struct DashboardActiveTicketsSection: View {
    @State private var ticketsVM = TicketListVM()
    
    var body: some View {
        Group {
            if !ticketsVM.tickets.isEmpty {
                BillingSectionCard("Active tickets", showsBackground: false) {
                    VStack(spacing: 12) {
                        ForEach(ticketsVM.tickets) {
                            TicketCard($0)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                        }
                    }
                }
            }
        }
        .task {
            await reload()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task {
                await reload()
            }
        }
    }
    
    private func reload() async {
        ticketsVM.showClosed = false
        await ticketsVM.fetchTickets()
    }
}

#Preview {
    NavigationStack {
        DashboardActiveTicketsSection()
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
