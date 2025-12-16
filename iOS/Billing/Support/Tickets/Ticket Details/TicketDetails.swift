import SwiftUI

struct TicketDetails: View {
    @State private var vm: TicketDetailsVM
    
    init(_ ticket: SupportTicketDTO) {
        _vm = State(initialValue: TicketDetailsVM(ticket))
    }
    
    @State private var selectedMedia: String? = nil
    @State private var isMediaPresented = false
    @State private var attachments: [PendingAttachment] = []
    
    var body: some View {
        VStack(spacing: 0) {
            TicketMessageList($selectedMedia)
            
            Divider()
            
            TicketMessageComposer(text: $vm.composerText, attachments: $attachments, isSending: vm.isSending) {
                let success = await vm.sendMessage(attachments: attachments)
                
                if success {
                    attachments = []
                }
            }
        }
        .navigationTitle(vm.ticket.title)
        .navigationSubtitle("Ticket #\(vm.ticket.id)")
        .navigationBarTitleDisplayMode(.inline)
        .environment(vm)
        .task {
            vm.start()
        }
        .onDisappear {
            vm.stop()
        }
        .onChange(of: selectedMedia) { _, newValue in
            isMediaPresented = newValue != nil
        }
        .toolbar {
            ToolbarItem {
                Button {
#warning("Does nothing")
                } label: {
                    Text(vm.ticket.status.rawValue.capitalized)
                        .foregroundStyle(vm.ticket.status.color)
                }
                .buttonStyle(.glassProminent)
                .tint(vm.ticket.status.color.opacity(0.3))
            }
        }
        .fullScreenCover(isPresented: $isMediaPresented, onDismiss: { selectedMedia = nil }) {
            NavigationStack {
                if let media = selectedMedia {
                    SupportMedia(mediaPath: media) { selectedMedia = nil }
                } else {
                    Color.clear
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TicketDetails(.init(id: 1, title: "Example issue", status: .open, userId: 1, createdAt: Date(), updatedAt: Date()))
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
