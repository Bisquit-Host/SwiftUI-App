import ScrechKit
import PteroNet

struct CloudKeyCard: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    @Binding private var selectedKey: String
    @Bindable private var key: APIKey
    private let validate: () -> Void
    
    init(_ selectedKey: Binding<String>,
         key: APIKey,
         validate: @escaping () -> Void
    ) {
        _selectedKey = selectedKey
        self.key = key
        self.validate = validate
    }
    
    @FocusState private var focus
    
    var body: some View {
        Button {
            Keychain.save(key: "selectedApiKey", value: key.key)
            selectedKey = key.key
            validate()
            settings.authSucced()
        } label: {
            HStack {
                VStack(alignment: .leading) {
#if os(watchOS) && os(tvOS)
                    Text(key.name)
                        .headline(.semibold)
#else
                    TextField("Unnamed", text: $key.name)
                        .headline(.semibold)
                        .focused($focus)
                        .textFieldStyle(.plain)
#endif
                    Text(showFirstEightLetters(key.key))
                        .footnote()
                        .foregroundStyle(.secondary)
                }
#if !os(watchOS)
                Spacer()
                
                Image(systemName: "doc.on.clipboard")
                    .subheadline(.semibold)
                    .foregroundStyle(.green)
#endif
            }
        }
        .foregroundStyle(.foreground)
#if !os(watchOS)
        .contextMenu {
            CloudKeyContextMenu(key, focus: _focus)
        }
#endif
    }
    
    private func showFirstEightLetters(_ string: String) -> String {
        if string.count <= 8 {
            return string
        } else {
            let index = string.index(string.startIndex, offsetBy: 8)
            let truncatedString = string[string.startIndex..<index]
            let dottedString = truncatedString + "..."
            
            return String(dottedString)
        }
    }
}

#Preview {
    List {
        CloudKeyCard(
            .constant(""),
            key: .init(
                "Preview Key",
                key: "ptlc_1234567890"
            )) {}
    }
    .environmentObject(SettingsStorage())
}
