import ScrechKit

struct PasskeyCard: View {
    private let passkey: PasskeyListItem
    private let onDelete: (() -> Void)?
    
    init(_ passkey: PasskeyListItem, onDelete: (() -> Void)? = nil) {
        self.passkey = passkey
        self.onDelete = onDelete
    }
    
    private var tint: Color {
        passkey.userVerified ? .blue : .yellow
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .frame(38)
                        .glassEffect(.regular.tint(tint.opacity(0.25)))
                    
                    Image(systemName: "key.fill")
                        .foregroundStyle(tint)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(passkey.nickname.flatMap { $0.isEmpty ? nil : $0 } ?? "Passkey #\(passkey.id)")
                        .subheadline(.semibold)
                    
                    badge
                    
                    Group {
                        if let lastUsed = formattedDate(passkey.lastUsedAt) {
                            Text("Last used \(lastUsed)")
                            
                        } else if let createdText = formattedDate(passkey.createdAt) {
                            Text("Created \(createdText)")
                        }
                    }
                    .footnote()
                    .secondary()
                    
                    if !passkey.transports.isEmpty {
                        transportTag(passkey.transports.joined(separator: " • "))
                    }
                }
                
                Spacer()
                
                if let onDelete {
                    SFButton("trash") {
                        onDelete()
                    }
                    .tint(.red)
                    .buttonStyle(.borderless)
                }
            }
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
    }
    
    private func formattedDate(_ date: Date?) -> String? {
        guard let date else { return nil }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private var badge: some View {
        HStack(spacing: 6) {
            Image(systemName: passkey.userVerified ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                .footnote()
            
            Text(passkey.userVerified ? "Verified" : "Not verified")
                .caption()
        }
        .foregroundStyle(passkey.userVerified ? .green : .yellow)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background((passkey.userVerified ? Color.green : .yellow).opacity(0.12), in: .capsule)
    }
    
    private func transportTag(_ text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "bolt.horizontal.fill")
                .caption2()
                .secondary()
            
            Text(text)
                .caption()
                .secondary()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(.primary.opacity(0.04), in: .capsule)
        .overlay {
            Capsule()
                .stroke(.primary.opacity(0.04), lineWidth: 1)
        }
    }
}
