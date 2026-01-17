import SwiftUI
import WebKit

struct SupportView: View {
    @State private var vm = TicketListVM()
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Tickets", systemImage: "questionmark.bubble", value: 0) {
                TicketList()
            }
            
            Tab("Wiki", systemImage: "books.vertical", value: 1) {
                WebView(url: URL(string: Endpoint.bisquitWiki)!)
            }
        }
        .navigationTitle("Support")
        .environment(vm)
        .toolbar {
            if selectedTab == 0 {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New", systemImage: "plus", action: vm.createNewTicket)
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
