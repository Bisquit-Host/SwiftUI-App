import SwiftUI

struct CustomDialog: View {
    var title: LocalizedStringKey
    var content: LocalizedStringKey?
    var button1: ButtonConfig
    var button2: ButtonConfig?
    var addsTextField = false
    var textFieldHint: LocalizedStringKey = ""
    
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .title3(.bold)
            
            if let content {
                Text(content)
                    .fontSize(14)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            }
            
            if addsTextField {
                TextField(textFieldHint, text: $text)
                    .focused($isFocused)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background {
                        Capsule()
                            .fill(.gray.opacity(0.1))
                    }
                    .padding(.bottom, 5)
            }
            
            ButtonView(button1)
            
            if let button2 {
                ButtonView(button2)
                    .padding(.top, -5)
            }
        }
        .padding(15)
        .glassEffect(in: .rect(cornerRadius: 32))
        .frame(maxWidth: 310)
        .compositingGroup()
        .task {
            isFocused = true
        }
    }
    
    private func ButtonView(_ config: ButtonConfig) -> some View {
        Button {
            config.action(addsTextField ? text : "")
        } label: {
            Text(config.content)
                .bold()
                .foregroundStyle(config.foreground)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial, in: .capsule)
        }
    }
    
    struct ButtonConfig {
        var content: LocalizedStringKey
        var foreground: Color
        var action: (String) -> () = { _ in }
    }
}
