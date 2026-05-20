import ScrechKit

struct DatabaseDetailsRow: View {
    private let title: LocalizedStringKey
    private let value: String?
    private let privacySensitive: Bool
    
    init(_ title: LocalizedStringKey, value: String?, privacySensitive: Bool = false) {
        self.title = title
        self.value = value
        self.privacySensitive = privacySensitive
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .subheadline(.semibold)
                
                Text(displayValue(for: value))
                    .privacySensitive(privacySensitive)
                    .footnote()
                    .secondary()
            }
            
            Spacer()
            
            if let copyValue = copyValue(for: value) {
#if !os(tvOS)
                Button {
                    Pasteboard.copy(copyValue)
                    SystemAlert.copied()
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.plain)
                .frame(width: 24, height: 24, alignment: .center)
#endif
            }
        }
    }
    
    private func copyValue(for value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        
        return value
    }
    
    private func displayValue(for value: String?) -> String {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return "Unavailable"
        }
        
        return value
    }
}

//#Preview {
//    DatabaseDetailsRow()
//}
