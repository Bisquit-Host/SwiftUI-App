import ScrechKit

struct BackupDetailsCopyRow: View {
    private let title: LocalizedStringKey
    private let value: String

    init(_ title: LocalizedStringKey, value: String) {
        self.title = title
        self.value = value
    }

    var body: some View {
        Button {
            Pasteboard.copy(value)
            SystemAlert.copied()
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)

                    Text(value)
                        .monospaced()
                        .footnote()
                        .secondary()
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "doc.on.doc")
                    .secondary()
            }
            .foregroundStyle(.foreground)
        }
    }
}

#Preview {
    List {
        BackupDetailsCopyRow("Checksum", value: "kopia:49c4cf1cbf1785ff77f7c0bba98d17d5")
    }
    .darkSchemePreferred()
}
