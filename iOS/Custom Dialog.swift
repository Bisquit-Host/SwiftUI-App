import SwiftUI

struct CustomDialog: View {
    var title: LocalizedStringKey
    var content: LocalizedStringKey?
    var image: Config
    var button1: Config
    var button2: Config?
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
                .background(image.tint, in: .circle)
                .background {
                    Circle()
                        .stroke(.ultraThickMaterial, lineWidth: 8)
                }
            
            Text(title)
                .title3(.bold)
            
            if let content {
                Text(content)
                    .fontSize(14)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(.gray)
                    .padding(.vertical, 4)
            }
            
            if addsTextField {
                TextField(textFieldHint, text: $text)
                    .focused($isFocused)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
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
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .padding(.top, 30)
        }
        .frame(maxWidth: 310)
        .compositingGroup()
        .task {
            isFocused = true
        }
    }
    
    private func ButtonView(_ config: Config) -> some View {
        Button {
            config.action(addsTextField ? text : "")
        } label: {
            Text(config.content)
                .bold()
                .foregroundStyle(config.foreground)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(config.tint, in: .rect(cornerRadius: 10))
        }
    }
    
    struct Config {
        var content: String
        var tint: Color
        var foreground: Color
        var action: (String) -> () = { _ in }
    }
}
