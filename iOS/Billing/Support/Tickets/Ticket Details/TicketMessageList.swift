import SwiftUI

struct TicketMessageList: View {
    @Environment(TicketDetailsVM.self) private var vm
    
    @Binding private var selectedMedia: String?
    @State private var didInitialScroll = false
    
    init(_ selectedMedia: Binding<String?>) {
        _selectedMedia = selectedMedia
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if vm.messages.isEmpty {
                    ContentUnavailableView("No messages yet", systemImage: "ellipsis.bubble")
                } else {
                    ForEach(vm.messages) { message in
                        TicketMessage(
                            message: message,
                            isCurrentUser: message.userId == vm.ticket.userId,
                            isDeleting: vm.isDeletingMessage(message.id)
                        ) {
                            selectedMedia = $0
                        } onDelete: {
                            Task {
                                _ = await vm.deleteMessage(message)
                            }
                        }
                        .listRowSeparator(.hidden)
                        .scenePadding(.horizontal)
                    }
                }
            }
            .task {
                if !vm.messages.isEmpty {
                    scrollToBottom(proxy, animated: false)
                    didInitialScroll = true
                }
            }
            .onChange(of: vm.messages) { oldValue, newValue in
                guard !newValue.isEmpty else { return }
                
                if oldValue.isEmpty || didInitialScroll == false {
                    scrollToBottom(proxy, animated: false)
                    didInitialScroll = true
                } else {
                    scrollToBottom(proxy)
                }
            }
        }
        .scrollIndicators(.never)
        .contentMargins(.bottom, 5, for: .scrollContent)
    }
    
    private func scrollToBottom(_ proxy: ScrollViewProxy, animated: Bool = true) {
        guard let lastMessage = vm.messages.last else { return }
        
        if animated {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}

//#Preview {
//    TicketMessageList()
//        .darkSchemePreferred()
//}
