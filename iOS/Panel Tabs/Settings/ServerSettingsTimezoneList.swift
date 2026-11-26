import ScrechKit

struct ServerSettingsTimezoneList: View {
    @Environment(ServerSettingsVM.self) private var vm
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""

    private let timezones = TimeZone.knownTimeZoneIdentifiers

    private var filteredTimezones: [String] {
        guard !searchText.isEmpty else {
            return timezones
        }

        let query = searchText.replacing(" ", with: "_")

        return timezones.filter {
            $0.localizedStandardContains(query) || $0.localizedStandardContains(searchText)
        }
    }

    var body: some View {
        List {
            if searchText.isEmpty {
                ServerSettingsTimezoneRow(String(localized: "Server default"), isSelected: vm.timezone.isEmpty) {
                    select("")
                }
            }

            ForEach(filteredTimezones, id: \.self) { timezone in
                ServerSettingsTimezoneRow(timezone, isSelected: vm.timezone == timezone) {
                    select(timezone)
                }
            }
        }
        .navigationTitle("Timezone")
        .searchable(text: $searchText, prompt: "Search timezones")
        .overlay {
            if filteredTimezones.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
    }

    private func select(_ timezone: String) {
        vm.timezone = timezone
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ServerSettingsTimezoneList()
    }
    .darkSchemePreferred()
    .environment(ServerSettingsVM(""))
}
