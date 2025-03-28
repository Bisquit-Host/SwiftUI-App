import SwiftUI

struct CustomDialog: View {
    var title: LocalizedStringKey
    var content: LocalizedStringKey?
    var image: ImageConfig
    var button1: ButtonConfig
    var button2: ButtonConfig?
    var addsTextField = false
    var textFieldHint: LocalizedStringKey = ""
    
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: image.content)
                .title()
                .foregroundStyle(image.foreground)
                .frame(width: 65, height: 65)
                .background(.ultraThinMaterial, in: .circle)
            
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
        .padding([.horizontal, .bottom], 15)
        .background {
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial)
                .padding(.top, 30)
        }
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
                .background(config.tint.secondary, in: .capsule)
        }
    }
    
    struct ButtonConfig {
        var content: LocalizedStringKey
        var tint: Color
        var foreground: Color
        var action: (String) -> () = { _ in }
    }
    
    struct ImageConfig {
        var content: String
        var tint: Color
        var foreground: Color
        var action: (String) -> () = { _ in }
    }
}
