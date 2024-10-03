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
    
    @State private var alertRename = false
    
    var body: some View {
        Button {
            Keychain.save(key: "selectedApiKey", value: key.key)
            selectedKey = key.key
            validate()
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(key.name)
                        .headline(.semibold)
                    
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
            CloudKeyContextMenu($alertRename, key: key)
        }
#endif
        .alert("Rename", isPresented: $alertRename) {
            TextField("Unnamed", text: $key.name)
                .autocorrectionDisabled()
            
            Button("Save") {
                
            }
        }
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
    @Previewable @State var selectedKey = ""
    
    List {
        CloudKeyCard(
            $selectedKey,
            key: .init(
                "Preview Key",
                key: "ptlc_1234567890"
            )) {}
    }
    .environmentObject(SettingsStorage())
}
