import ScrechKit

struct SFTPDetailsRow: View {
    private let title: LocalizedStringKey
    private let value: String?
    private let displayValue: String?
    private let isLoading: Bool
    private let copy: (String) -> Void

    init(
        _ title: LocalizedStringKey,
        value: String?,
        displayValue: String? = nil,
        isLoading: Bool = false,
        copy: @escaping (String) -> Void
    ) {
        self.title = title
        self.value = value
        self.displayValue = displayValue
        self.isLoading = isLoading
        self.copy = copy
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)

                if isLoading {
                    ProgressView()
                } else {
                    Text(displayText)
                        .secondary()
                }
            }

            Spacer()

            if let value {
                Button {
                    copy(value)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .secondary()
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(.primary)
    }

    private var displayText: String {
        if let displayValue {
            return displayValue
        }

        guard let value, !value.isEmpty else {
            return "Unavailable"
        }

        return value
    }
}
