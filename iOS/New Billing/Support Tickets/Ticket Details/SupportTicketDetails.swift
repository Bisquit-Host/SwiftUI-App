import SwiftUI

struct SupportTicketDetails: View {
    @State private var vm: SupportTicketDetailsVM
    @EnvironmentObject private var store: ValueStore
    
    init(_ ticket: SupportTicketDTO) {
        _vm = State(initialValue: SupportTicketDetailsVM(ticket))
    }
    
    @State private var selectedMedia: String? = nil
    @State private var attachments: [PendingAttachment] = []
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                HStack {
                    Text(vm.ticket.title)
                        .headline()
                    
                    Spacer()
                    
                    Text(vm.ticket.status.rawValue.capitalized)
                        .caption(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(vm.ticket.status.color.opacity(0.12), in: .capsule)
                        .foregroundStyle(vm.ticket.status.color)
                }
                
                if vm.messages.isEmpty {
                    ContentUnavailableView("No messages yet", systemImage: "ellipsis.bubble")
                } else {
                    ForEach(vm.messages) {
                        TicketMessageRow(message: $0, isCurrentUser: $0.userId == vm.ticket.userId) {
                            selectedMedia = $0
                        }
                        .listRowSeparator(.hidden)
                        .scenePadding(.horizontal)
                    }
                }
            }
            .scrollIndicators(.never)
            
            Divider()
            
            SupportMessageComposer(text: $vm.composerText, attachments: $attachments, isSending: vm.isSending) {
                let success = await vm.sendMessage(accessToken: store.testAccessToken, attachments: attachments)
                
                if success {
                    attachments = []
                }
            }
        }
        .navigationTitle("Ticket #\(vm.ticket.id)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            vm.start(accessToken: store.testAccessToken)
        }
        .onDisappear {
            vm.stop()
        }
        .fullScreenCover(Binding(get: { selectedMedia != nil }, set: { if !$0 { selectedMedia = nil } })) {
            NavigationStack {
                if let media = selectedMedia {
                    SupportMedia(mediaPath: media, accessToken: store.testAccessToken) {
                        selectedMedia = nil
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SupportTicketDetails(.init(id: 1, title: "Example issue", status: .open, userId: 1, createdAt: Date(), updatedAt: Date()))
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
