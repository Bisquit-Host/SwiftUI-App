import ScrechKit

struct DatabaseInstanceStatRow: View {
    private let title: LocalizedStringKey
    private let systemImage: String
    private let value: String
    private let limit: String?
    
    init(_ title: LocalizedStringKey, systemImage: String, value: String, limit: String? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.value = value
        self.limit = limit
    }
    
    var body: some View {
        LabeledContent {
            if let limit {
                Text("\(value) / \(limit)")
                    .monospacedDigit()
            } else {
                Text(value)
                    .monospacedDigit()
            }
        } label: {
            Label(title, systemImage: systemImage)
        }
        .contentTransition(.numericText())
    }
}

#Preview {
    List {
        DatabaseInstanceStatRow("Memory", systemImage: "memorychip", value: "128 MB", limit: "512 MB")
    }
    .darkSchemePreferred()
}
