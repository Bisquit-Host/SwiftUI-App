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
                if let url = URL(string: "https://wiki.bisquit.host") {
                    WebView(url: url)
                }
            }
        }
        .navigationTitle("Support")
        .environment(vm)
        .toolbar {
            if selectedTab == 0 {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New", systemImage: "plus") {
                        vm.createNewTicket()
                    }
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
