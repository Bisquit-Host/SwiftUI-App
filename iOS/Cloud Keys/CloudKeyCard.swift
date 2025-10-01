import ScrechKit
import PteroNet

struct CloudKeyCard: View {
    @Binding private var selectedKey: String
    @Bindable private var key: APIKey
    private let validate: () -> Void
    
    init(
        _ selectedKey: Binding<String>,
        key: APIKey,
        validate: @escaping () -> Void
    ) {
        _selectedKey = selectedKey
        self.key = key
        self.validate = validate
    }
    
    @State private var alertRename = false
    
    private var isSelected: Bool {
        key.key == selectedKey
    }
    
    var body: some View {
        Button {
            clearAllCookies()
            Keychain.save(key.key, forKey: "selectedApiKey")
            selectedKey = key.key
            validate()
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    if key.name.isEmpty {
                        Text(firstEightLetters(key.key))
                            .headline(.semibold)
                    } else {
                        Text(key.name)
                            .headline(.semibold)
                        
                        Text(firstEightLetters(key.key))
                            .footnote()
                            .secondary()
                    }
                }
#if !os(watchOS)
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .subheadline(.semibold)
                        .foregroundStyle(.green)
                }
#endif
            }
        }
        .disabled(isSelected)
        .foregroundStyle(.foreground)
#if !os(watchOS)
        .contextMenu {
            CloudKeyContextMenu($alertRename, key: key)
        }
#endif
        .alert("Rename", isPresented: $alertRename) {
            TextField("New name", text: $key.name)
                .autocorrectionDisabled()
            
            Button("Save") {}
        }
    }
    
    private func firstEightLetters(_ string: String) -> String {
        String(string.prefix(8)) + "..."
    }
}

#Preview {
    @Previewable @State var selectedKey = ""
    
    List {
        CloudKeyCard(
            $selectedKey,
            key: .init("Preview Key", key: "ptlc_1234567890")
        ) {}
    }
    .darkSchemePreferred()
}
