import ScrechKit

struct ServerSettingsTimezoneRow: View {
    private let title: String
    private let isSelected: Bool
    private let action: () -> Void

    init(_ title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(Color.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                        .bold()
                }
            }
        }
    }
}

#Preview {
    List {
        ServerSettingsTimezoneRow("Europe/Berlin", isSelected: true) {}
        ServerSettingsTimezoneRow("Europe/London", isSelected: false) {}
    }
    .darkSchemePreferred()
}
