import SwiftUI
import BisquitoNet

struct TicketDetails: View {
    @State private var vm: TicketDetailsVM
    
    init(_ ticket: SupportTicketDTO) {
        _vm = State(initialValue: TicketDetailsVM(ticket))
    }
    
    @State private var selectedMedia: String? = nil
    @State private var isMediaPresented = false
    @State private var alertCloseTicket = false
    @State private var attachments: [PendingAttachment] = []
    
    var body: some View {
        VStack(spacing: 0) {
            TicketMessageList($selectedMedia)
        }
        .safeAreaInset(edge: .bottom) {
            if vm.ticket.status != .closed {
                TicketMessageComposer(text: $vm.composerText, attachments: $attachments, isSending: vm.isSending) {
                    let success = await vm.sendMessage(attachments: attachments)
                    
                    if success {
                        attachments = []
                    }
                }
            }
        }
        .navigationTitle(vm.ticket.title)
        .navSubtitle("Ticket #\(vm.ticket.id)")
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
                    alertCloseTicket = true
                } label: {
                    if vm.isClosing {
                        ProgressView()
                    } else {
                        Text(vm.ticket.status.loc)
                            .foregroundStyle(vm.ticket.status.color)
                    }
                }
#if !os(visionOS)
                .buttonStyle(.glassProminent)
#endif
                .tint(vm.ticket.status.color.opacity(0.3))
                .disabled(vm.ticket.status == .closed || vm.isClosing)
            }
        }
        .alert("Close this ticket?", isPresented: $alertCloseTicket) {
            Button("Close Ticket", systemImage: "checkmark.circle", role: .destructive) {
                Task {
                    attachments = []
                    _ = await vm.closeTicket()
                }
            }
        } message: {
            Text("You will not be able to send more messages in this ticket")
        }
        .fullScreenCover(isPresented: $isMediaPresented, onDismiss: { selectedMedia = nil }) {
            NavigationStack {
                if let media = selectedMedia {
                    SupportMedia(mediaPath: media) {
                        selectedMedia = nil
                    }
                } else {
                    Color.clear
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TicketDetails(.init(id: 1, title: "Example issue", status: .new, userId: 1, createdAt: Date(), updatedAt: Date()))
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
