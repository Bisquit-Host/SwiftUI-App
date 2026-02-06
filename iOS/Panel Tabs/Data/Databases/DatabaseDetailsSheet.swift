import ScrechKit
import PteroNet

struct DatabaseDetailsSheet: View {
    private let database: DatabaseAttributes

    init(_ database: DatabaseAttributes) {
        self.database = database
    }

    var body: some View {
        List {
            Section {
                detailRow(title: "Name", value: database.name)
                detailRow(title: "Host", value: database.host.address)
                detailRow(title: "Port", value: String(database.host.port))
                detailRow(title: "User", value: database.username)
                detailRow(title: "Password", value: database.password)
                detailRow(title: "Connections from", value: database.connectionsFrom)
            }
        }
        .navigationTitle("Database details")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Copy all", action: copyAll)
            }
        }
    }

    @ViewBuilder
    private func detailRow(title: String, value: String?) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .subheadline(.semibold)

                Text(displayValue(for: value))
                    .footnote()
                    .secondary()
            }

            Spacer()

            if let copyValue = copyValue(for: value) {
                Button {
                    Pasteboard.copy(copyValue)
                    SystemAlert.copied()
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.plain)
                .frame(width: 24, height: 24, alignment: .center)
            }
        }
    }

    private func displayValue(for value: String?) -> String {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return "Unavailable"
        }

        return value
    }

    private func copyValue(for value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }

        return value
    }

    private func copyAll() {
        let credentials = [
            ("Name", database.name),
            ("Host", database.host.address),
            ("Port", String(database.host.port)),
            ("User", database.username),
            ("Password", database.password ?? "Unavailable"),
            ("Connections from", database.connectionsFrom ?? "Unavailable")
        ]
        .map { key, value in
            "\(key): \(value)"
        }
        .joined(separator: "\n")

        Pasteboard.copy(credentials)
        SystemAlert.copied()
    }
}

#Preview {
    NavigationStack {
        DatabaseDetailsSheet(PreviewProp.databaseAttributes)
    }
    .darkSchemePreferred()
}
