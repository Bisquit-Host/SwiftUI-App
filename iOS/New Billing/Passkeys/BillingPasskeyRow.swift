import SwiftUI

struct BillingPasskeyRow: View {
    private let passkey: PasskeyListItem
    
    init(_ passkey: PasskeyListItem) {
        self.passkey = passkey
    }
    
    private let isoFormatter = ISO8601DateFormatter()
    
    private let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "key.fill")
                    .foregroundStyle(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(passkey.nickname.flatMap { $0.isEmpty ? nil : $0 } ?? "Passkey #\(passkey.id)")
                        .subheadline(.semibold)
                    
                    if let createdText = formattedDate(passkey.createdAt) {
                        Text("Created \(createdText)")
                            .footnote()
                            .secondary()
                    }
                    
                    if let lastUsed = formattedDate(passkey.lastUsedAt) {
                        Text("Last used \(lastUsed)")
                            .footnote()
                            .secondary()
                    }
                }
                
                Spacer()
                
                if passkey.userVerified {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                }
            }
            
            if !passkey.transports.isEmpty {
                Label(passkey.transports.joined(separator: ", "), systemImage: "bolt.horizontal.fill")
                    .caption2()
                    .secondary()
            }
        }
        .padding(.vertical, 6)
    }
    
    private func formattedDate(_ value: String?) -> String? {
        guard let value, let date = isoFormatter.date(from: value) else {
            return nil
        }
        
        return relativeFormatter.localizedString(for: date, relativeTo: .init())
    }
}
