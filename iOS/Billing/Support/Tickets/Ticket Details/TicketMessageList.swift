import SwiftUI

struct TicketMessageList: View {
    @Environment(TicketDetailsVM.self) private var vm
    
    @Binding private var selectedMedia: String?
    
    init(_ selectedMedia: Binding<String?>) {
        _selectedMedia = selectedMedia
    }
    
    var body: some View {
        ScrollView {
            if vm.messages.isEmpty {
                ContentUnavailableView("No messages yet", systemImage: "ellipsis.bubble")
            } else {
                ForEach(vm.messages) {
                    TicketMessage(message: $0, isCurrentUser: $0.userId == vm.ticket.userId) {
                        selectedMedia = $0
                    }
                    .listRowSeparator(.hidden)
                    .scenePadding(.horizontal)
                }
            }
        }
        .scrollIndicators(.never)
    }
}

//#Preview {
//    TicketMessageList()
//        .darkSchemePreferred()
//}
