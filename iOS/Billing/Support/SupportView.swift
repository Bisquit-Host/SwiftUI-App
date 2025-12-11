import SwiftUI

struct SupportView: View {
    @State private var vm = TicketListVM()
    
    var body: some View {
        TabView {
            Tab("Tickets", systemImage: "ticket") {
                TicketList()
            }
        }
        .navigationTitle("Support")
        .environment(vm)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("New", systemImage: "plus") {
                    vm.createNewTicket()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SupportView()
    }
    .environment(TicketListVM())
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
