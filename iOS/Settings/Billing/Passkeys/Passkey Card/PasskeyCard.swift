import ScrechKit
import BisquitoNet

struct PasskeyCard: View {
    @Environment(PasskeyListVM.self) private var vm
    
    private let passkey: PasskeyListItem
    
    init(_ passkey: PasskeyListItem) {
        self.passkey = passkey
    }
    
    @State private var alertDelete = false
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .frame(38)
#if !os(visionOS)
                    .glassEffect(.regular.tint(.blue.opacity(0.25)))
#endif
                Image(systemName: "key.fill")
                    .foregroundStyle(.blue)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(passkey.nickname.flatMap { $0.isEmpty ? nil : $0 } ?? "Passkey #\(passkey.id)")
                    .lineLimit(1)
                    .subheadline(.semibold)
                
                HStack {
                    if let lastUsed = formattedDate(passkey.lastUsedAt) {
                        Label(lastUsed, systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    } else if let createdText = formattedDate(passkey.createdAt) {
                        Label(createdText, systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    }
                }
                .footnote()
                .secondary()
                .labelIconToTitleSpacing(4)
            }
            
            Spacer()
            
            Image(systemName: passkey.userVerified ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(.green.gradient)
                .padding(.trailing)
                .fontSize(20)
        }
        .padding(14)
        .background {
            Capsule()
                .fill(.background.opacity(0.8))
        }
        .overlay {
            Capsule()
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
        formatter.unitsStyle = .short
        
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
