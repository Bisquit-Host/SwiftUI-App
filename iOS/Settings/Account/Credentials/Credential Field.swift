import SwiftUI

struct CredentialField: View {
    @State private var text: String
    private let hint: String
    private let isSecure: Bool
    private let textType: UITextContentType
    private let keyboardType: UIKeyboardType
    
    init(
        text: String,
        hint: String,
        isSecure: Bool,
        textType: UITextContentType,
        keyboardType: UIKeyboardType = .default
    ) {
        self.text = text
        self.hint = hint
        self.isSecure = isSecure
        self.textType = textType
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(hint, text: $text)
            } else {
                TextField(hint, text: $text)
            }
        }
        .textContentType(textType)
        .textFieldStyle(.roundedBorder)
        .keyboardType(keyboardType)
        .clipShape(.rect(cornerRadius: 15))
        .padding(.horizontal, 8)
    }
}
