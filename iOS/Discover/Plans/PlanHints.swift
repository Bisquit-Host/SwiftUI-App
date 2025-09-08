import ScrechKit

struct PlanHints: View {
    private let hints = [
        "Processor Cores (CPU)": "cpu",
        "Memory (RAM)":          "memorychip",
        "Storage":               "internaldrive",
        "Websites":              "macwindow.on.rectangle",
        "MySQL Databases":       "server.rack"
    ]
    
    var body: some View {
        DisclosureGroup("Hints") {
            ForEach(hints.sorted(by: >), id: \.key) { hint, icon in
                ListButton(LocalizedStringKey(hint), icon: icon)
            }
        }
        .padding(5)
        .padding(.horizontal, 8)
        .background(.regularMaterial, in: .rect(cornerRadius: 5))
        .foregroundStyle(.primary)
        .padding(.horizontal)
    }
}

#Preview {
    List {
        PlanHints()
    }
}
