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
        VStack(alignment: .leading) {
            Text(title)
                .subheadline(.bold)
            
            Text(displayValue(for: value))
                .footnote()
                .secondary()
                .privacySensitive(privacySensitive)
        }
    }
    
    private func displayValue(for value: String?) -> String {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return "Unavailable"
        }
        
        return value
    }
}

#Preview {
    List {
        DatabaseDetailsRow("Name", value: "s1_example")
    }
    .darkSchemePreferred()
}
