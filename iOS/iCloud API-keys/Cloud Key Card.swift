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
                        .secondary()
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
}
