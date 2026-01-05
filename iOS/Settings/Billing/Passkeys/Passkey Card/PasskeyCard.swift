import ScrechKit
import BisquitoNet

struct PasskeyCard: View {
    @Environment(PasskeyListVM.self) private var vm
    
    private let passkey: PasskeyListItem
    private let tint: Color
    
    init(_ passkey: PasskeyListItem) {
        self.passkey = passkey
        tint = passkey.userVerified ? .blue : .yellow
    }
    
    @State private var alertDelete = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .frame(38)
#if !os(visionOS)
                        .glassEffect(.regular.tint(tint.opacity(0.25)))
#endif
                    Image(systemName: "key.fill")
                        .foregroundStyle(tint)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(passkey.nickname.flatMap { $0.isEmpty ? nil : $0 } ?? "Passkey #\(passkey.id)")
                        .lineLimit(1)
                        .subheadline(.semibold)
                    
                    PasskeyCardVerifiedBadge(passkey)
                    
                    if !passkey.transports.isEmpty {
                        PasskeyCardTransportTag(passkey.transports.joined(separator: " • "))
                    }
                }
                
                Spacer()
            }
            
            Group {
                if let lastUsed = formattedDate(passkey.lastUsedAt) {
                    Text("Last used: \(lastUsed)")
                }
                
                if let createdText = formattedDate(passkey.createdAt) {
                    Text("Created: \(createdText)")
                }
            }
            .footnote()
            .secondary()
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.background.opacity(0.8))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.primary.opacity(0.04), lineWidth: 1)
        }
        .contextMenu {
            Button("Delete", systemImage: "trash", role: .destructive) {
                alertDelete = true
            }
        }
        .alert("Delete Passkey", isPresented: $alertDelete) {
            Button("Delete", role: .destructive, action: delete)
        }
    }
    
    private func delete() {
        Task {
            await vm.deletePasskey(passkey)
        }
    }
    
    private func formattedDate(_ date: Date?) -> String? {
        guard let date else { return nil }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
