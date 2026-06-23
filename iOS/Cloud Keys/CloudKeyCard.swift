import ScrechKit
import Calagopus

struct CloudKeyCard: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var selectedKey: String
    @Bindable private var key: APIKey
    private let validate: () async -> Void
    
    init(_ selectedKey: Binding<String>, key: APIKey, validate: @escaping () async -> Void) {
        _selectedKey = selectedKey
        self.key = key
        self.validate = validate
    }
    
    @State private var alertRename = false
    
    var body: some View {
        let isSelected = key.key == selectedKey
        
        Button(action: select) {
            HStack {
                VStack(alignment: .leading) {
                    if key.name.isEmpty {
                        Text(firstEightSymbols(key.key))
                            .headline(.semibold)
                    } else {
                        Text(key.name)
                            .headline(.semibold)
                        
                        Text(firstEightSymbols(key.key))
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
            
            Button("Save", role: .confirm) {}
        }
    }
    
    private func firstEightSymbols(_ string: String) -> String {
        String(string.prefix(8)) + "..."
    }
    
    private func select() {
        clearAllCookies()
        Keychain.save(key.key, forKey: "selectedApiKey")
        selectedKey = key.key
        dismiss()
        
        Task {
            await validate()
        }
    }
}

#Preview {
    @Previewable @State var selectedKey = ""
    
    List {
        CloudKeyCard($selectedKey, key: .init("Preview Key", key: "ptlc_1234567890")) {}
    }
    .darkSchemePreferred()
}
